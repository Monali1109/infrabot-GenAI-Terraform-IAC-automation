import re
import shutil
from datetime import datetime
from pathlib import Path
from typing import List, Optional, Tuple

BASE_DIR = Path(__file__).parent.parent
BACKUPS_DIR = BASE_DIR / "output" / "backups"
LOGS_DIR = BASE_DIR / "logs"
CHANGES_LOG = LOGS_DIR / "changes.log"

# Matches: resource "aws_instance" "my_server"
_RESOURCE_RE = re.compile(r'^resource\s+"([^"]+)"\s+"([^"]+)"', re.MULTILINE)


# ---------------------------------------------------------------------------
# Rule 1 — Auto-backup before touching any .tf file
# ---------------------------------------------------------------------------

def backup_tf_file(tf_path: Path) -> Optional[Path]:
    """Copy tf_path into output/backups/ with a timestamp suffix. Returns backup path."""
    tf_path = Path(tf_path)
    if not tf_path.exists():
        return None

    BACKUPS_DIR.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_name = f"{tf_path.stem}_{timestamp}.tf.bak"
    backup_path = BACKUPS_DIR / backup_name
    shutil.copy2(tf_path, backup_path)
    return backup_path


# ---------------------------------------------------------------------------
# Rule 2 — Parse existing .tf files to extract resource names
# ---------------------------------------------------------------------------

def parse_resources(tf_path: Path) -> List[Tuple[str, str]]:
    """Return list of (resource_type, resource_name) tuples found in a .tf file."""
    tf_path = Path(tf_path)
    if not tf_path.exists():
        return []
    return _RESOURCE_RE.findall(tf_path.read_text(encoding="utf-8"))


# ---------------------------------------------------------------------------
# Rule 3 — Duplicate check
# ---------------------------------------------------------------------------

def check_duplicate(tf_path: Path, resource_type: str, resource_name: str) -> bool:
    """Return True if (resource_type, resource_name) already exists in the file."""
    return (resource_type, resource_name) in parse_resources(tf_path)


# ---------------------------------------------------------------------------
# Rule 4 + 1 + 3 + 5 — Safe append entry point
# ---------------------------------------------------------------------------

def append_to_tf(
    tf_path: Path,
    content: str,
    engineer: str,
    cloud_provider: str,
    resource_type: str,
    resource_name: str,
) -> dict:
    """
    Safely append a Terraform resource block to a .tf file.

    Steps (in order):
      1. Duplicate check  — abort if resource already exists.
      2. Backup           — copy current file to output/backups/.
      3. Append           — add content in append mode only.
      4. Log              — write entry to logs/changes.log.

    Returns:
        {"success": bool, "message": str}
    """
    tf_path = Path(tf_path)

    # Rule 3 — reject duplicates before any file mutation
    if check_duplicate(tf_path, resource_type, resource_name):
        return {
            "success": False,
            "message": (
                f"Duplicate detected: resource '{resource_type}.{resource_name}' "
                f"already exists in '{tf_path}'. No changes made."
            ),
        }

    # Rule 1 — backup existing file
    backup_path = backup_tf_file(tf_path)

    # Rule 4 — append mode only, never 'w'
    tf_path.parent.mkdir(parents=True, exist_ok=True)
    with open(tf_path, "a", encoding="utf-8") as f:
        # Separate from prior content with a blank line
        if tf_path.exists() and tf_path.stat().st_size > 0:
            f.write("\n")
        f.write(content.rstrip("\n") + "\n")

    # Rule 5 — log the change
    _log_change(engineer, cloud_provider, resource_type, resource_name, str(tf_path))

    backup_note = f" Backup: '{backup_path}'." if backup_path else ""
    return {
        "success": True,
        "message": (
            f"Appended '{resource_type}.{resource_name}' to '{tf_path}'.{backup_note}"
        ),
    }


# ---------------------------------------------------------------------------
# Rule 5 — Change log writer
# ---------------------------------------------------------------------------

def _log_change(
    engineer: str,
    cloud_provider: str,
    resource_type: str,
    resource_name: str,
    file_modified: str,
) -> None:
    """Append one structured line to logs/changes.log."""
    LOGS_DIR.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    entry = (
        f"[{timestamp}] "
        f"engineer={engineer} | "
        f"provider={cloud_provider} | "
        f"resource_type={resource_type} | "
        f"resource_name={resource_name} | "
        f"file={file_modified}\n"
    )
    with open(CHANGES_LOG, "a", encoding="utf-8") as f:
        f.write(entry)


# ---------------------------------------------------------------------------
# Rule 6 — List all resources in a .tf file
# ---------------------------------------------------------------------------

def list_resources(tf_path: Path) -> str:
    """Return a formatted string of every resource block found in a .tf file."""
    tf_path = Path(tf_path)
    resources = parse_resources(tf_path)

    if not resources:
        return f"No resources found in '{tf_path.name}'."

    lines = [f"Resources in '{tf_path.name}' ({len(resources)} total):"]
    for i, (rtype, rname) in enumerate(resources, start=1):
        lines.append(f"  {i:>2}. {rtype}.{rname}")
    return "\n".join(lines)
