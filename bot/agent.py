"""InfraBot — conversational Terraform provisioning assistant (Claude Code SDK)."""

import json
import os
import re
import subprocess
import sys
from pathlib import Path

from colorama import Fore, Style, init as colorama_init
from jinja2 import Environment, FileSystemLoader, TemplateNotFound

sys.path.insert(0, str(Path(__file__).parent))
from file_handler import check_duplicate as _check_duplicate
from file_handler import append_to_tf
from git_manager import full_pr_pipeline, is_git_repo, init_repo, log_git_action

colorama_init(autoreset=True)

BASE_DIR      = Path(__file__).parent.parent
TEMPLATES_DIR = BASE_DIR / "templates"
OUTPUT_DIR    = BASE_DIR / "output"
CHANGES_LOG   = BASE_DIR / "logs" / "changes.log"

# Maps (workflow, cloud) → Terraform resource type used in the output .tf file
_RESOURCE_TYPES: dict[tuple[str, str], str] = {
    ("server",      "aws"):   "aws_instance",
    ("server",      "gcp"):   "google_compute_instance",
    ("server",      "azure"): "azurerm_virtual_machine",
    ("firewall",    "aws"):   "aws_security_group_rule",
    ("firewall",    "gcp"):   "google_compute_firewall",
    ("firewall",    "azure"): "azurerm_network_security_rule",
    ("permissions", "aws"):   "aws_iam_user_policy",
    ("permissions", "gcp"):   "google_project_iam_member",
    ("permissions", "azure"): "azurerm_role_assignment",
}

# ─────────────────────────────────────────────────────────────────────────────
# Claude CLI discovery
# ─────────────────────────────────────────────────────────────────────────────

def _find_claude_bin() -> str:
    """Locate the claude CLI binary installed alongside Claude Code."""
    npm_roots = [
        Path.home() / ".npm-global" / "node_modules",
        Path(os.getenv("APPDATA", "")) / "npm" / "node_modules",
        Path(os.getenv("APPDATA", "")) / "roaming" / "npm" / "node_modules",
        Path("/usr/local/lib/node_modules"),
        Path("/usr/lib/node_modules"),
    ]
    for root in npm_roots:
        candidate = root / "@anthropic-ai" / "claude-code" / "bin" / "claude.exe"
        if candidate.exists():
            return str(candidate)
        candidate_nix = root / "@anthropic-ai" / "claude-code" / "bin" / "claude"
        if candidate_nix.exists():
            return str(candidate_nix)

    raise FileNotFoundError(
        "claude CLI not found. Make sure Claude Code is installed: "
        "npm install -g @anthropic-ai/claude-code"
    )


CLAUDE_BIN = _find_claude_bin()

# ─────────────────────────────────────────────────────────────────────────────
# System prompt
# ─────────────────────────────────────────────────────────────────────────────

SYSTEM_PROMPT = """
You are InfraBot, a friendly and precise AI infrastructure assistant. You help
engineers provision cloud infrastructure on AWS, GCP, and Azure by guiding them
through structured workflows and generating valid Terraform configurations.

You support three workflows. Start every session by greeting the engineer and
asking which workflow they need.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WORKFLOW 1 — SERVER PROVISIONING
Collect in this order, one question at a time:
  1. Cloud provider (AWS, GCP, or Azure)
  2. Hostname — Terraform resource name (lowercase, hyphens ok, no spaces)
  3. Instance type / VM size
       AWS examples  : t3.micro · t3.medium · m5.large
       GCP examples  : e2-standard-2 · n2-standard-4
       Azure examples: Standard_B2s · Standard_D2s_v3
  4. Image / OS image
       AWS  : AMI ID (e.g. ami-0abcdef1234567890)
       GCP  : boot disk image (e.g. debian-cloud/debian-11)
       Azure: ask for publisher, offer, and SKU separately
              (e.g. Canonical / UbuntuServer / 20.04-LTS)
  5. OS type: Linux or Windows
  6. Cloud-specific extras
       AWS  : cpu_credits — standard or unlimited
       GCP  : zone (e.g. us-central1-a) and network name (default is fine)
       Azure: location, resource group name, admin username

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WORKFLOW 2 — FIREWALL RULES
Collect in this order, one question at a time:
  1. Cloud provider
  2. Rule name (resource_name — lowercase, hyphens ok)
  3. Direction: inbound/ingress  OR  outbound/egress
  4. Protocol: TCP, UDP, or ICMP
  5. Port number (skip entirely if ICMP)
  6. Source IP / CIDR  (e.g. 10.0.0.0/8 or 0.0.0.0/0)
  7. Destination IP / CIDR  (for outbound/egress rules)
  8. Cloud-specific extras
       AWS  : Security Group ID (sg-xxxxxxxxx)
       GCP  : network name, priority (default 1000)
       Azure: resource group, NSG name, priority (100–4096)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WORKFLOW 3 — USER PERMISSIONS
Collect in this order, one question at a time:
  1. Cloud provider
  2. Resource name (identifier for the policy / role assignment)
  3. Access type: server/compute  OR  database (RDS / Cloud SQL / Azure SQL)
  4. Cloud-specific extras
       AWS  : IAM username, AWS account ID, region,
              and instance ID (server) or DB identifier (database)
       GCP  : project ID, member string
              (e.g. user:alice@example.com)
       Azure: principal ID (object ID), scope (ARM resource ID)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RULES:
- Ask exactly ONE question at a time. Wait for the answer before continuing.
- Always give 2–3 examples for technical fields.
- After collecting all inputs, display a numbered summary and ask the engineer
  to confirm before proceeding. Only invoke tools AFTER they confirm.
- If check_duplicate returns duplicate=true: explain the conflict and STOP.
- If no duplicate: invoke render_template and display the result in a fenced
  ```hcl code block.
- After the rendered output, tell the engineer which file it goes to.
- After rendering, ask if the user wants to create a GitHub PR for approval.
  If they say yes (or request a PR at any point), invoke create_pr.
  If they provide a reviewer email or GitHub username, include it.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TOOL PROTOCOL
You have three tools. To call a tool, output a line starting with INVOKE_TOOL:
followed immediately by a JSON object. Put nothing else on that line.

  INVOKE_TOOL: {"__tool__": "check_duplicate", "workflow": "<server|firewall|permissions>", "cloud_provider": "<aws|gcp|azure>", "resource_name": "<name>"}

  INVOKE_TOOL: {"__tool__": "render_template", "workflow": "<server|firewall|permissions>", "cloud_provider": "<aws|gcp|azure>", "template_inputs": {<key>: <value>}}

  INVOKE_TOOL: {"__tool__": "create_pr", "workflow": "<server|firewall|permissions>", "cloud_provider": "<aws|gcp|azure>", "resource_name": "<name>", "environment": "<production|staging|development>", "notes": "<optional description>", "reviewer": "<optional github username or empty string>"}

The create_pr tool automatically:
  1. Saves the Terraform config to output/{cloud}/main.tf
  2. Creates a feature branch (infra/{cloud}/{resource_name}_{timestamp})
  3. Commits the changes with a structured message
  4. Pushes the branch to GitHub
  5. Opens a Pull Request with a review checklist
  6. Optionally assigns a reviewer

After invoking a tool you will receive [TOOL RESULT: ...]. Base your next
response on that result. Never fabricate a tool result.

When create_pr succeeds, display:
  - The PR URL as a clickable link
  - The branch name
  - The commit hash
  - Confirm that the reviewer has been assigned (if provided)
  - Tell the engineer their approver will review it on GitHub
""".strip()

# ─────────────────────────────────────────────────────────────────────────────
# Agent
# ─────────────────────────────────────────────────────────────────────────────

class InfraBot:
    def __init__(self) -> None:
        self.session_id: str | None = None
        self.last_render: dict | None = None
        self.last_check:  dict | None = None
        self.last_pr:     dict | None = None
        # Config — set by app.py from sidebar settings
        self.github_token:  str = ""
        self.github_remote: str = ""

    # ── public interface ──────────────────────────────────────────────────────

    def chat(self, user_message: str) -> str:
        """Send a user turn and return the agent's final text reply."""
        current_message = user_message

        while True:
            response = self._invoke(current_message)
            text = response.get("result", "")

            tool_call = self._parse_tool_call(text)
            if tool_call:
                tool_name = tool_call.pop("__tool__")
                result    = self._dispatch(tool_name, tool_call)
                current_message = f"[TOOL RESULT: {json.dumps(result)}]"
                continue

            return text

    def reset(self) -> None:
        self.session_id  = None
        self.last_render = None
        self.last_check  = None
        self.last_pr     = None

    # ── claude CLI invocation ─────────────────────────────────────────────────

    def _invoke(self, message: str) -> dict:
        cmd = [CLAUDE_BIN, "-p", message, "--output-format", "json"]

        if self.session_id:
            cmd.extend(["--resume", self.session_id])
        else:
            cmd.extend(["--system-prompt", SYSTEM_PROMPT])

        proc = subprocess.run(
            cmd, capture_output=True, text=True, stdin=subprocess.DEVNULL,
        )

        for line in proc.stdout.splitlines():
            line = line.strip()
            if not line.startswith("{"):
                continue
            try:
                data = json.loads(line)
            except json.JSONDecodeError:
                continue

            if data.get("is_error") and self.session_id:
                self.session_id = None
                return self._invoke(message)

            self.session_id = data.get("session_id", self.session_id)
            return data

        raise RuntimeError(
            f"claude CLI returned unexpected output.\n"
            f"stdout: {proc.stdout[:300]}\nstderr: {proc.stderr[:300]}"
        )

    # ── tool call parsing ─────────────────────────────────────────────────────

    def _parse_tool_call(self, text: str) -> dict | None:
        idx = text.find("INVOKE_TOOL:")
        if idx == -1:
            return None
        json_start = text.find("{", idx)
        if json_start == -1:
            return None
        try:
            obj, _ = json.JSONDecoder().raw_decode(text, json_start)
            return obj if isinstance(obj, dict) and "__tool__" in obj else None
        except json.JSONDecodeError:
            return None

    # ── tool dispatcher ───────────────────────────────────────────────────────

    def _dispatch(self, name: str, inputs: dict) -> dict:
        handlers = {
            "check_duplicate":  self._tool_check_duplicate,
            "render_template":  self._tool_render_template,
            "create_pr":        self._tool_create_pr,
        }
        handler = handlers.get(name)
        if handler is None:
            return {"error": f"Unknown tool: '{name}'"}
        return handler(**inputs)

    # ── tool: check_duplicate ─────────────────────────────────────────────────

    def _tool_check_duplicate(
        self, workflow: str, cloud_provider: str, resource_name: str
    ) -> dict:
        resource_type = _RESOURCE_TYPES.get((workflow, cloud_provider))
        if not resource_type:
            return {"error": f"No resource type mapped for ({workflow}, {cloud_provider})."}

        tf_path = OUTPUT_DIR / cloud_provider / "main.tf"
        exists  = _check_duplicate(tf_path, resource_type, resource_name)

        result = {
            "duplicate":     exists,
            "resource_type": resource_type,
            "resource_name": resource_name,
            "checked_file":  str(tf_path),
            "message": (
                f"CONFLICT: '{resource_type}.{resource_name}' already exists in "
                f"'{tf_path}'. No changes made."
                if exists else
                f"Clear: '{resource_type}.{resource_name}' does not exist yet in '{tf_path}'."
            ),
        }
        self.last_check = result
        return result

    # ── tool: render_template ─────────────────────────────────────────────────

    def _tool_render_template(
        self, workflow: str, cloud_provider: str, template_inputs: dict
    ) -> dict:
        template_dir  = TEMPLATES_DIR / cloud_provider
        template_file = f"{workflow}.j2"

        if not (template_dir / template_file).exists():
            return {
                "success": False,
                "error": f"Template not found: {template_dir / template_file}",
            }

        try:
            env = Environment(
                loader=FileSystemLoader(str(template_dir)),
                trim_blocks=True, lstrip_blocks=True,
            )
            rendered = env.get_template(template_file).render(**template_inputs)
            result = {
                "success":     True,
                "rendered":    rendered,
                "output_file": str(OUTPUT_DIR / cloud_provider / "main.tf"),
            }
            self.last_render = result
            return result
        except TemplateNotFound as exc:
            return {"success": False, "error": f"Template not found: {exc}"}
        except Exception as exc:
            return {"success": False, "error": f"Render error: {exc}"}

    # ── tool: create_pr ───────────────────────────────────────────────────────

    def _tool_create_pr(
        self,
        workflow: str,
        cloud_provider: str,
        resource_name: str,
        environment: str = "production",
        notes: str = "",
        reviewer: str = "",
    ) -> dict:
        """Automated pipeline: save → branch → commit → push → PR."""

        # Get resource type
        resource_type = _RESOURCE_TYPES.get((workflow, cloud_provider))
        if not resource_type:
            return {"success": False, "error": f"No resource type for ({workflow}, {cloud_provider})."}

        # Need rendered content from last render
        if not self.last_render or not self.last_render.get("rendered"):
            return {"success": False, "error": "No rendered template found. Run render_template first."}

        rendered = self.last_render["rendered"]
        tf_path  = Path(self.last_render["output_file"])

        # Need GitHub token
        token = self.github_token or os.getenv("GITHUB_TOKEN", "")
        if not token:
            return {
                "success": False,
                "error": "No GitHub token configured. Set it in ⚙️ GitHub Settings in the sidebar, or set GITHUB_TOKEN environment variable.",
            }

        # Get engineer name from the last check or default
        engineer = "infrabot-user"
        if self.last_check and self.last_check.get("resource_name"):
            engineer = self.last_check.get("engineer", engineer)

        # Run the full pipeline
        result = full_pr_pipeline(
            project_dir=BASE_DIR,
            tf_path=tf_path,
            rendered_content=rendered,
            cloud=cloud_provider,
            resource_type=resource_type,
            resource_name=resource_name,
            engineer=engineer,
            github_token=token,
            environment=environment,
            notes=notes,
            reviewer=reviewer,
            log_file=CHANGES_LOG,
        )

        self.last_pr = result

        if result["ok"]:
            return {
                "success":     True,
                "pr_url":      result["pr_url"],
                "pr_number":   result["pr_number"],
                "branch":      result["branch"],
                "commit_hash": result["commit_hash"],
                "reviewer":    reviewer,
                "message":     f"PR #{result['pr_number']} created successfully at {result['pr_url']}",
            }
        else:
            return {
                "success": False,
                "error":   result["message"],
                "steps":   result.get("steps", []),
            }

    # ── interactive CLI ───────────────────────────────────────────────────────

    def run(self) -> None:
        """Start an interactive terminal session."""
        _banner()
        opening = self.chat("Hello, I'm ready to get started.")
        _agent_print(opening)

        while True:
            try:
                user_input = input(
                    Fore.WHITE + Style.BRIGHT + "\nYou: " + Style.RESET_ALL
                ).strip()
            except (EOFError, KeyboardInterrupt):
                print(Fore.YELLOW + "\n\nSession ended.")
                break

            if not user_input:
                continue
            if user_input.lower() in ("exit", "quit", "bye"):
                print(Fore.YELLOW + "\nGoodbye! Generated files are in output/.")
                break

            _agent_print(self.chat(user_input))


# ─────────────────────────────────────────────────────────────────────────────
# CLI helpers
# ─────────────────────────────────────────────────────────────────────────────

def _banner() -> None:
    print(Fore.CYAN + Style.BRIGHT + "\n╔══════════════════════════════════════╗")
    print(Fore.CYAN + Style.BRIGHT +   "║         InfraBot  v2.0               ║")
    print(Fore.CYAN + Style.BRIGHT +   "║   Terraform Provisioning + Git PR    ║")
    print(Fore.CYAN + Style.BRIGHT +   "╚══════════════════════════════════════╝")
    print(Fore.YELLOW + "  Type 'exit' or 'quit' to end the session.\n")


def _agent_print(text: str) -> None:
    print(Fore.GREEN + Style.BRIGHT + "\nInfraBot: " + Style.RESET_ALL + text)


if __name__ == "__main__":
    InfraBot().run()
