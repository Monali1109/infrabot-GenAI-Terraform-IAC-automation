"""git_manager.py — Git + GitHub PR integration for InfraBot.

Handles: repo init, branching, commits, push, GitHub PR creation,
PR status checks, version history, and branch management.
"""

import os
import subprocess
import json
import datetime
import re
from pathlib import Path
from typing import Optional

try:
    import requests
    HAS_REQUESTS = True
except ImportError:
    HAS_REQUESTS = False


DEFAULT_BASE_BRANCH = "main"


def _run(cmd: list[str], cwd: str | Path | None = None) -> dict:
    """Run a git command and return {ok, stdout, stderr}."""
    try:
        result = subprocess.run(
            cmd, cwd=str(cwd) if cwd else None,
            capture_output=True, text=True, timeout=30,
        )
        return {"ok": result.returncode == 0, "stdout": result.stdout.strip(), "stderr": result.stderr.strip()}
    except Exception as e:
        return {"ok": False, "stdout": "", "stderr": str(e)}


# ── Repo setup ────────────────────────────────────────────────────────────────

def is_git_repo(project_dir: Path) -> bool:
    r = _run(["git", "rev-parse", "--is-inside-work-tree"], cwd=project_dir)
    return r["ok"] and r["stdout"] == "true"


def init_repo(project_dir: Path) -> dict:
    if is_git_repo(project_dir):
        return {"ok": True, "message": "Already a git repository.", "initialized": False}
    r = _run(["git", "init"], cwd=project_dir)
    if not r["ok"]:
        return {"ok": False, "message": f"git init failed: {r['stderr']}", "initialized": False}
    gitignore = project_dir / ".gitignore"
    if not gitignore.exists():
        gitignore.write_text("__pycache__/\n*.pyc\n.env\n.venv/\nnode_modules/\n*.tmp\n.DS_Store\n", encoding="utf-8")
    _run(["git", "add", "."], cwd=project_dir)
    _run(["git", "commit", "-m", "Initial commit — InfraBot project"], cwd=project_dir)
    return {"ok": True, "message": "Git repository initialized.", "initialized": True}


def has_remote(project_dir: Path) -> bool:
    r = _run(["git", "remote", "get-url", "origin"], cwd=project_dir)
    return r["ok"]


def add_remote(project_dir: Path, remote_url: str) -> dict:
    if has_remote(project_dir):
        r = _run(["git", "remote", "set-url", "origin", remote_url], cwd=project_dir)
    else:
        r = _run(["git", "remote", "add", "origin", remote_url], cwd=project_dir)
    return {"ok": r["ok"], "message": r["stderr"] if not r["ok"] else "Remote configured."}


def get_remote_url(project_dir: Path) -> Optional[str]:
    r = _run(["git", "remote", "get-url", "origin"], cwd=project_dir)
    return r["stdout"] if r["ok"] else None


def parse_github_repo(remote_url: str) -> Optional[tuple[str, str]]:
    m = re.match(r"https://(?:[^@]+@)?github\.com/([^/]+)/([^/.]+)", remote_url)
    if m:
        return m.group(1), m.group(2)
    m = re.match(r"git@github\.com:([^/]+)/([^/.]+)", remote_url)
    if m:
        return m.group(1), m.group(2)
    return None


# ── Branch operations ─────────────────────────────────────────────────────────

def get_current_branch(project_dir: Path) -> str:
    r = _run(["git", "rev-parse", "--abbrev-ref", "HEAD"], cwd=project_dir)
    return r["stdout"] if r["ok"] else "unknown"


def list_branches(project_dir: Path) -> list[str]:
    r = _run(["git", "branch", "--list", "--format=%(refname:short)"], cwd=project_dir)
    return [b.strip() for b in r["stdout"].splitlines() if b.strip()] if r["ok"] and r["stdout"] else []


def get_default_branch(project_dir: Path) -> str:
    branches = list_branches(project_dir)
    if "main" in branches: return "main"
    if "master" in branches: return "master"
    return branches[0] if branches else "main"


def create_branch(project_dir: Path, cloud: str, resource_type: str, resource_name: str, engineer: str) -> dict:
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    safe_name = re.sub(r"[^a-zA-Z0-9_-]", "_", resource_name)
    branch_name = f"infra/{cloud}/{safe_name}_{timestamp}"
    base = get_default_branch(project_dir)
    _run(["git", "checkout", base], cwd=project_dir)
    r = _run(["git", "checkout", "-b", branch_name], cwd=project_dir)
    if not r["ok"]:
        return {"ok": False, "branch": branch_name, "message": f"Failed: {r['stderr']}"}
    return {"ok": True, "branch": branch_name, "message": f"Branch '{branch_name}' created."}


def switch_branch(project_dir: Path, branch_name: str) -> dict:
    r = _run(["git", "checkout", branch_name], cwd=project_dir)
    return {"ok": r["ok"], "message": r["stderr"] if not r["ok"] else f"Switched to '{branch_name}'."}


def checkout_new_branch(project_dir: Path, branch_name: str) -> dict:
    """Create and checkout a branch with an explicit name (no auto-suffix)."""
    branch_name = branch_name.strip()
    if not branch_name:
        return {"ok": False, "branch": "", "message": "Branch name cannot be empty."}
    base = get_default_branch(project_dir)
    _run(["git", "checkout", base], cwd=project_dir)
    r = _run(["git", "checkout", "-b", branch_name], cwd=project_dir)
    if not r["ok"]:
        return {"ok": False, "branch": branch_name, "message": f"Failed: {r['stderr']}"}
    return {"ok": True, "branch": branch_name, "message": f"Branch '{branch_name}' created."}


# ── Commit operations ─────────────────────────────────────────────────────────

def commit_terraform(project_dir: Path, cloud: str, resource_type: str, resource_name: str, engineer: str, files: list[str] | None = None) -> dict:
    if files:
        for f in files:
            _run(["git", "add", f], cwd=project_dir)
    else:
        _run(["git", "add", f"output/{cloud}"], cwd=project_dir)
    _run(["git", "add", "logs/"], cwd=project_dir)

    commit_msg = (
        f"feat({cloud}): add {resource_type}.{resource_name}\n\n"
        f"Engineer: {engineer}\nCloud: {cloud.upper()}\n"
        f"Resource: {resource_type}.{resource_name}\n"
        f"Date: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
    )
    r = _run(["git", "commit", "-m", commit_msg], cwd=project_dir)
    if not r["ok"]:
        if "nothing to commit" in r["stdout"] + r["stderr"]:
            return {"ok": True, "message": "No changes to commit.", "commit_hash": ""}
        return {"ok": False, "message": f"Commit failed: {r['stderr']}"}
    h = _run(["git", "rev-parse", "--short", "HEAD"], cwd=project_dir)
    return {"ok": True, "message": f"Committed: {h['stdout']}", "commit_hash": h["stdout"] if h["ok"] else ""}


def push_branch(project_dir: Path, branch_name: str) -> dict:
    if not has_remote(project_dir):
        return {"ok": False, "message": "No remote configured."}
    r = _run(["git", "push", "-u", "origin", branch_name], cwd=project_dir)
    return {"ok": r["ok"], "message": f"Push failed: {r['stderr']}" if not r["ok"] else f"Pushed '{branch_name}'."}


# ── GitHub PR ─────────────────────────────────────────────────────────────────

def create_pull_request(project_dir: Path, branch_name: str, cloud: str, resource_type: str, resource_name: str, engineer: str, github_token: str, environment: str = "production", notes: str = "", reviewer: str = "") -> dict:
    if not HAS_REQUESTS:
        return {"ok": False, "pr_url": "", "pr_number": 0, "message": "requests library not installed."}

    remote_url = get_remote_url(project_dir)
    if not remote_url:
        return {"ok": False, "pr_url": "", "pr_number": 0, "message": "No GitHub remote configured."}

    parsed = parse_github_repo(remote_url)
    if not parsed:
        return {"ok": False, "pr_url": "", "pr_number": 0, "message": f"Cannot parse GitHub repo from: {remote_url}"}

    owner, repo = parsed
    base = get_default_branch(project_dir)

    title = f"[InfraBot] {cloud.upper()}: {resource_type}.{resource_name}"
    body = f"""## 🤖 InfraBot Deployment Request

| Field | Value |
|-------|-------|
| **Cloud Provider** | {cloud.upper()} |
| **Resource Type** | `{resource_type}` |
| **Resource Name** | `{resource_name}` |
| **Environment** | `{environment}` |
| **Requested By** | {engineer} |
| **Branch** | `{branch_name}` |
| **Date** | {datetime.datetime.now().strftime('%Y-%m-%d %H:%M')} |

### 📋 Description
This PR adds a new `{resource_type}.{resource_name}` resource for **{cloud.upper()}** ({environment}).

{f'### 📝 Notes' + chr(10) + notes if notes else ''}

### ✅ Approval Checklist
- [ ] Terraform config reviewed
- [ ] Resource naming follows convention
- [ ] Security groups / firewall rules verified
- [ ] Environment is correct ({environment})
- [ ] Ready to apply

---
*Generated by InfraBot — Deloitte Infrastructure Automation*
"""

    headers = {"Authorization": f"token {github_token}", "Accept": "application/vnd.github.v3+json"}
    payload = {"title": title, "body": body, "head": branch_name, "base": base}

    try:
        resp = requests.post(f"https://api.github.com/repos/{owner}/{repo}/pulls", headers=headers, json=payload, timeout=15)
        if resp.status_code == 201:
            data = resp.json()
            pr_url = data["html_url"]
            pr_number = data["number"]

            # Add reviewer if specified
            if reviewer:
                # Try to add as reviewer by username
                try:
                    requests.post(
                        f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}/requested_reviewers",
                        headers=headers,
                        json={"reviewers": [reviewer]},
                        timeout=10,
                    )
                except Exception:
                    pass  # reviewer add is best-effort

            return {"ok": True, "pr_url": pr_url, "pr_number": pr_number, "message": f"PR #{pr_number} created."}
        else:
            full = resp.json()
            err  = full.get("message", resp.text)
            errors = full.get("errors", [])
            detail = f"GitHub API {resp.status_code}: {err}"
            if errors:
                detail += f" | errors: {errors}"
            print(f"[PR DEBUG] status={resp.status_code} body={full}")
            return {"ok": False, "pr_url": "", "pr_number": 0, "message": detail}
    except Exception as e:
        return {"ok": False, "pr_url": "", "pr_number": 0, "message": f"Request failed: {e}"}


def get_pr_status(project_dir: Path, pr_number: int, github_token: str) -> dict:
    if not HAS_REQUESTS:
        return {"ok": False, "state": "unknown", "message": "requests library not installed."}
    remote_url = get_remote_url(project_dir)
    parsed = parse_github_repo(remote_url) if remote_url else None
    if not parsed:
        return {"ok": False, "state": "unknown", "message": "Cannot parse GitHub repo."}
    owner, repo = parsed
    headers = {"Authorization": f"token {github_token}", "Accept": "application/vnd.github.v3+json"}
    try:
        resp = requests.get(f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}", headers=headers, timeout=15)
        if resp.status_code != 200:
            return {"ok": False, "state": "unknown", "message": f"GitHub API error: {resp.status_code}"}
        pr = resp.json()
        state = pr["state"]
        merged = pr.get("merged", False)
        rev_resp = requests.get(f"https://api.github.com/repos/{owner}/{repo}/pulls/{pr_number}/reviews", headers=headers, timeout=15)
        reviews = rev_resp.json() if rev_resp.status_code == 200 else []
        approved = any(r.get("state") == "APPROVED" for r in reviews)
        changes_requested = any(r.get("state") == "CHANGES_REQUESTED" for r in reviews)
        return {"ok": True, "state": "merged" if merged else state, "merged": merged, "approved": approved, "changes_requested": changes_requested, "review_count": len(reviews), "pr_url": pr["html_url"], "title": pr["title"], "message": "PR status retrieved."}
    except Exception as e:
        return {"ok": False, "state": "unknown", "message": f"Request failed: {e}"}


# ── Version history ───────────────────────────────────────────────────────────

def get_commit_history(project_dir: Path, max_count: int = 20, cloud_filter: str | None = None) -> list[dict]:
    fmt = "--format=%H|||%h|||%s|||%an|||%ai"
    cmd = ["git", "log", fmt, f"-{max_count}"]
    if cloud_filter:
        cmd.extend(["--", f"output/{cloud_filter}/"])
    r = _run(cmd, cwd=project_dir)
    if not r["ok"] or not r["stdout"]:
        return []
    commits = []
    for line in r["stdout"].splitlines():
        parts = line.split("|||")
        if len(parts) >= 5:
            commits.append({"hash": parts[0], "short_hash": parts[1], "message": parts[2], "author": parts[3], "date": parts[4]})
    return commits


def get_file_diff(project_dir: Path, commit_hash: str) -> str:
    r = _run(["git", "show", "--stat", "--patch", commit_hash], cwd=project_dir)
    return r["stdout"] if r["ok"] else r["stderr"]


def get_repo_status(project_dir: Path) -> dict:
    return {"is_repo": is_git_repo(project_dir), "current_branch": get_current_branch(project_dir), "has_remote": has_remote(project_dir), "remote_url": get_remote_url(project_dir), "branches": list_branches(project_dir)}


def log_git_action(log_file: Path, engineer: str, action: str, details: str = "") -> None:
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_file.parent.mkdir(parents=True, exist_ok=True)
    with open(log_file, "a", encoding="utf-8") as f:
        f.write(f"[{timestamp}] [GIT:{action.upper()}] engineer={engineer} | {details}\n")


# ── Full automated pipeline ──────────────────────────────────────────────────

def full_pr_pipeline(
    project_dir: Path,
    tf_path: Path,
    rendered_content: str,
    cloud: str,
    resource_type: str,
    resource_name: str,
    engineer: str,
    github_token: str,
    environment: str = "production",
    notes: str = "",
    reviewer: str = "",
    log_file: Path | None = None,
) -> dict:
    """Execute the full pipeline: save → branch → commit → push → PR.

    Returns a dict with all results and the final PR URL.
    """
    steps = []

    # 0. Ensure git is initialized
    if not is_git_repo(project_dir):
        init_result = init_repo(project_dir)
        steps.append({"step": "git_init", **init_result})

    # 1. Create feature branch
    branch_result = create_branch(project_dir, cloud, resource_type, resource_name, engineer)
    steps.append({"step": "create_branch", **branch_result})
    if not branch_result["ok"]:
        return {"ok": False, "steps": steps, "message": f"Branch failed: {branch_result['message']}"}
    branch_name = branch_result["branch"]

    # 2. Write the terraform file
    tf_path.parent.mkdir(parents=True, exist_ok=True)
    try:
        existing = tf_path.read_text(encoding="utf-8") if tf_path.exists() else ""
        separator = "\n\n" if existing.strip() else ""
        tf_path.write_text(existing + separator + rendered_content + "\n", encoding="utf-8")
        steps.append({"step": "write_tf", "ok": True, "message": f"Written to {tf_path}"})
    except Exception as e:
        steps.append({"step": "write_tf", "ok": False, "message": str(e)})
        return {"ok": False, "steps": steps, "message": f"Write failed: {e}"}

    # 3. Commit
    commit_result = commit_terraform(project_dir, cloud, resource_type, resource_name, engineer)
    steps.append({"step": "commit", **commit_result})
    if not commit_result["ok"]:
        return {"ok": False, "steps": steps, "message": f"Commit failed: {commit_result['message']}"}

    # 4. Push
    push_result = push_branch(project_dir, branch_name)
    steps.append({"step": "push", **push_result})
    if not push_result["ok"]:
        return {"ok": False, "steps": steps, "message": f"Push failed: {push_result['message']}"}

    # 5. Create PR
    pr_result = create_pull_request(
        project_dir, branch_name, cloud, resource_type, resource_name,
        engineer, github_token, environment, notes, reviewer,
    )
    steps.append({"step": "create_pr", **pr_result})

    # 6. Log
    if log_file and pr_result["ok"]:
        log_git_action(log_file, engineer, "auto_pr_pipeline",
            f"branch={branch_name} | pr=#{pr_result.get('pr_number','')} | "
            f"resource={resource_type}.{resource_name} | reviewer={reviewer}")

    # 7. Switch back to default branch
    base = get_default_branch(project_dir)
    switch_branch(project_dir, base)

    return {
        "ok": pr_result["ok"],
        "steps": steps,
        "branch": branch_name,
        "commit_hash": commit_result.get("commit_hash", ""),
        "pr_url": pr_result.get("pr_url", ""),
        "pr_number": pr_result.get("pr_number", 0),
        "message": pr_result.get("message", ""),
    }
