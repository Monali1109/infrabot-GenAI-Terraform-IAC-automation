"""session_store.py — Persist and restore InfraBot chat sessions to data/sessions.json."""

import json
import uuid
from datetime import datetime
from pathlib import Path
from typing import Any

BASE_DIR      = Path(__file__).parent.parent
DATA_DIR      = BASE_DIR / "data"
SESSIONS_FILE = DATA_DIR / "sessions.json"

# Widget key prefixes used by provisioning_forms.py
_FORM_KEY_PREFIXES = ("aws_", "gcp_", "az_")


def _ensure_dir() -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)


def _load_all() -> dict:
    if not SESSIONS_FILE.exists():
        return {}
    try:
        return json.loads(SESSIONS_FILE.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError):
        return {}


def _save_all(data: dict) -> None:
    _ensure_dir()
    SESSIONS_FILE.write_text(
        json.dumps(data, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )


# ─────────────────────────────────────────────────────────────────────────────
# Public API
# ─────────────────────────────────────────────────────────────────────────────

def new_session_id() -> str:
    return str(uuid.uuid4())


def save_session(
    session_id: str,
    engineer: str,
    cloud: str,
    workflow: str,
    messages: list,
    pending: dict | None,
    phase: str,
    form_state: dict,
) -> None:
    all_sessions = _load_all()
    all_sessions[session_id] = {
        "session_id": session_id,
        "engineer":   engineer,
        "cloud":      cloud,
        "workflow":   workflow,
        "messages":   messages,
        "pending":    pending,
        "phase":      phase,
        "form_state": form_state,
        "timestamp":  datetime.now().isoformat(timespec="seconds"),
    }
    _save_all(all_sessions)


def load_session(session_id: str) -> dict | None:
    return _load_all().get(session_id)


def list_sessions() -> list[dict]:
    """Return all sessions sorted by most recent first."""
    sessions = list(_load_all().values())
    sessions.sort(key=lambda s: s.get("timestamp", ""), reverse=True)
    return sessions


def delete_session(session_id: str) -> None:
    all_sessions = _load_all()
    all_sessions.pop(session_id, None)
    _save_all(all_sessions)


def clear_all_sessions() -> None:
    _save_all({})


def snapshot_form_state(session_state: Any) -> dict:
    """Capture all provisioning form widget values from st.session_state."""
    result = {}
    for key in list(session_state.keys()):
        if any(key.startswith(p) for p in _FORM_KEY_PREFIXES):
            try:
                val = session_state[key]
                if isinstance(val, (str, int, float, bool)) or val is None:
                    result[key] = val
            except Exception:
                pass
    return result


def restore_form_state(session_state: Any, form_state: dict) -> None:
    """Write saved widget values back into st.session_state so forms pre-fill."""
    for key, val in form_state.items():
        try:
            session_state[key] = val
        except Exception:
            pass
