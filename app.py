"""InfraBot — Streamlit web interface for AI-powered Terraform provisioning."""

import sys
from pathlib import Path

import streamlit as st

sys.path.insert(0, str(Path(__file__).parent / "bot"))
from agent import InfraBot, _RESOURCE_TYPES
from file_handler import append_to_tf, parse_resources
from provisioning_forms import render_provisioning_form
from session_store import (
    save_session, list_sessions, clear_all_sessions,
    snapshot_form_state, restore_form_state, new_session_id,
)
from git_manager import (
    is_git_repo,
    init_repo,
    has_remote,
    add_remote,
    get_remote_url,
    get_current_branch,
    get_default_branch,
    list_branches,
    create_branch,
    checkout_new_branch,
    switch_branch,
    commit_terraform,
    push_branch,
    create_pull_request,
    get_pr_status,
    get_commit_history,
    get_file_diff,
    get_repo_status,
    log_git_action,
)

BASE_DIR    = Path(__file__).parent
OUTPUT_DIR  = BASE_DIR / "output"
CHANGES_LOG = BASE_DIR / "logs" / "changes.log"

_WORKFLOW_LABELS = ["Server Provisioning", "Firewall Rules", "User Permissions"]
_WORKFLOW_KEYS   = {
    "Server Provisioning": "server",
    "Firewall Rules":      "firewall",
    "User Permissions":    "permissions",
}
_WORKFLOW_LABELS_BY_KEY = {v: k for k, v in _WORKFLOW_KEYS.items()}

# ─────────────────────────────────────────────────────────────────────────────
# Page config
# ─────────────────────────────────────────────────────────────────────────────

st.set_page_config(
    page_title="InfraBot — Terraform Provisioning",
    page_icon="🤖",
    layout="wide",
    initial_sidebar_state="expanded",
)

st.markdown("""
<style>
    .stChatMessage { border-radius: 10px; margin-bottom: 4px; }
    code { font-size: 0.85rem; }
    .stSpinner > div { font-size: 0.85rem; color: #666; }
</style>
""", unsafe_allow_html=True)

# ─────────────────────────────────────────────────────────────────────────────
# Session state
# ─────────────────────────────────────────────────────────────────────────────

_DEFAULTS: dict = {
    "messages":        [],       # chat history
    "bot":             None,     # InfraBot instance
    "phase":           "chat",   # "chat" | "preview" | "git_commit" | "pr_created" | "saved"
    "pending":         None,     # render data waiting for confirmation
    "save_result":     None,     # result dict from append_to_tf
    # Git state
    "git_branch":      "",       # feature branch name
    "git_commit_hash": "",       # latest commit hash
    "pr_url":          "",       # GitHub PR URL
    "pr_number":       0,        # GitHub PR number
    "environment":     "production",
    "pr_notes":        "",
    # Settings (persisted in session)
    "github_token":    "",
    "github_remote":   "",
    "show_history":    False,    # toggle version history panel
    "session_id":        "",       # UUID for current session
    "_last_prefill_key": "",      # tracks last cloud+workflow for form pre-fill
    "branch_mode_radio": "🔀 Auto-generate",
    "custom_branch_name": "",
}
for _k, _v in _DEFAULTS.items():
    if _k not in st.session_state:
        st.session_state[_k] = _v

# ─────────────────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────────────────

def _reset() -> None:
    st.session_state.messages           = []
    st.session_state.phase              = "chat"
    st.session_state.pending            = None
    st.session_state.save_result        = None
    st.session_state.git_branch         = ""
    st.session_state.git_commit_hash    = ""
    st.session_state.pr_url             = ""
    st.session_state.pr_number          = 0
    st.session_state.environment        = "production"
    st.session_state.pr_notes           = ""
    st.session_state.session_id           = new_session_id()
    st.session_state["_last_prefill_key"] = ""
    st.session_state.branch_mode_radio    = "🔀 Auto-generate"
    st.session_state.custom_branch_name   = ""
    bot = st.session_state.bot
    if bot:
        bot.reset()
        bot.last_render = None
        bot.last_check  = None
    # Switch back to default branch
    if is_git_repo(BASE_DIR):
        base = get_default_branch(BASE_DIR)
        switch_branch(BASE_DIR, base)


def _get_or_create_bot() -> InfraBot:
    if st.session_state.bot is None:
        st.session_state.bot = InfraBot()
    return st.session_state.bot


def _resource_count(cloud: str) -> int:
    tf = OUTPUT_DIR / cloud / "main.tf"
    return len(parse_resources(tf)) if tf.exists() else 0

# ─────────────────────────────────────────────────────────────────────────────
# Sidebar
# ─────────────────────────────────────────────────────────────────────────────

with st.sidebar:
    st.title("🤖 InfraBot")
    st.caption("AI-powered Terraform provisioning")
    st.divider()

    cloud_label    = st.selectbox("☁️ Cloud Provider", ["AWS", "GCP", "Azure"], key="cloud_select")
    workflow_label = st.selectbox("⚙️ Workflow", _WORKFLOW_LABELS, key="workflow_select")
    engineer       = st.text_input("👤 Your Name", placeholder="e.g. alice", key="engineer_name")

    st.divider()

    if st.button("🔄 New Session", use_container_width=True):
        _reset()
        st.rerun()

    st.divider()

    # ── Git status ────────────────────────────────────────────────────────────
    st.markdown("**🔀 Git Status**")
    _is_repo = is_git_repo(BASE_DIR)

    if _is_repo:
        _cur_branch = get_current_branch(BASE_DIR)
        _has_remote = has_remote(BASE_DIR)
        _remote_url = get_remote_url(BASE_DIR) or "None"

        st.caption(f"Branch: `{_cur_branch}`")
        st.caption(f"Remote: {'✅' if _has_remote else '⬜'} `{_remote_url[:40]}{'…' if len(_remote_url) > 40 else ''}`")

        _branches = list_branches(BASE_DIR)
        if len(_branches) > 1:
            with st.expander(f"📂 Branches ({len(_branches)})"):
                for _b in _branches:
                    _marker = "→ " if _b == _cur_branch else "  "
                    st.caption(f"{_marker}`{_b}`")
    else:
        st.caption("⬜ Git not initialized")

    st.divider()

    # ── Version history toggle ────────────────────────────────────────────────
    if _is_repo:
        if st.button(
            "📜 Version History" if not st.session_state.show_history else "💬 Back to Chat",
            use_container_width=True,
        ):
            st.session_state.show_history = not st.session_state.show_history
            st.rerun()

    st.divider()

    # ── Output files ──────────────────────────────────────────────────────────
    st.markdown("**📁 Output files**")
    for _cloud in ["aws", "gcp", "azure"]:
        _tf    = OUTPUT_DIR / _cloud / "main.tf"
        _count = _resource_count(_cloud)
        _icon  = "✅" if _tf.exists() else "⬜"
        st.caption(f"{_icon} `{_cloud}/main.tf` — {_count} resource(s)")

    # ── Phase indicator ───────────────────────────────────────────────────────
    st.divider()
    _phase_icons = {
        "chat":       "💬 Chat",
        "preview":    "📋 Preview",
        "git_commit": "🔀 Git Commit",
        "pr_created": "🔗 PR Created",
        "saved":      "✅ Saved",
    }
    st.caption(f"**Phase:** {_phase_icons.get(st.session_state.phase, st.session_state.phase)}")

    # ── Resume Session ────────────────────────────────────────────────────────
    st.divider()
    st.markdown("**📂 Resume Session**")
    _saved_sessions = list_sessions()
    if _saved_sessions:
        _sess_labels = [
            f"{s['engineer']} — {s['cloud'].upper()} {s['workflow']} — {s['timestamp'][:16]}"
            for s in _saved_sessions
        ]
        _resume_idx = st.selectbox(
            "resume_select",
            range(len(_sess_labels)),
            format_func=lambda i: _sess_labels[i],
            label_visibility="collapsed",
            key="resume_session_idx",
        )
        _rcol1, _rcol2 = st.columns(2)
        with _rcol1:
            if st.button("▶️ Resume", use_container_width=True, key="btn_resume"):
                _s = _saved_sessions[_resume_idx]
                st.session_state.session_id              = _s["session_id"]
                st.session_state.messages                = _s["messages"]
                st.session_state.pending                 = _s.get("pending")
                st.session_state.phase                   = _s.get("phase", "chat")
                st.session_state["_last_prefill_key"]    = ""
                st.session_state["cloud_select"]         = _s["cloud"].upper()
                st.session_state["workflow_select"]      = _WORKFLOW_LABELS_BY_KEY.get(_s["workflow"], _WORKFLOW_LABELS[0])
                st.session_state["engineer_name"]        = _s["engineer"]
                restore_form_state(st.session_state, _s.get("form_state", {}))
                if st.session_state.bot:
                    st.session_state.bot.reset()
                    st.session_state.bot.last_render = None
                    st.session_state.bot.last_check  = None
                st.rerun()
        with _rcol2:
            if st.button("🗑️ Clear History", use_container_width=True, key="btn_clear_hist"):
                clear_all_sessions()
                st.rerun()
    else:
        st.caption("No saved sessions yet.")

    # ── GitHub Settings (collapsible) ─────────────────────────────────────────
    st.divider()
    with st.expander("⚙️ GitHub Settings"):
        st.session_state.github_token = st.text_input(
            "GitHub Token (PAT)",
            value=st.session_state.github_token,
            type="password",
            placeholder="ghp_xxxxxxxxxxxx",
            help="Personal Access Token with repo scope",
        )
        st.session_state.github_remote = st.text_input(
            "GitHub Remote URL",
            value=st.session_state.github_remote or (get_remote_url(BASE_DIR) or ""),
            placeholder="https://github.com/org/repo.git",
        )
        if st.button("💾 Save Settings", use_container_width=True):
            if st.session_state.github_remote.strip():
                _r = add_remote(BASE_DIR, st.session_state.github_remote.strip())
                if _r["ok"]:
                    st.success("Remote saved!")
                else:
                    st.error(_r["message"])
            st.rerun()

# ─────────────────────────────────────────────────────────────────────────────
# Boot guard
# ─────────────────────────────────────────────────────────────────────────────

if not engineer.strip():
    st.markdown("## 👋 Welcome to InfraBot")
    st.info("Enter your name in the sidebar to begin a session.")
    st.stop()

if not st.session_state.session_id:
    st.session_state.session_id = new_session_id()

# ─────────────────────────────────────────────────────────────────────────────
# Auto-init git if needed
# ─────────────────────────────────────────────────────────────────────────────

if not is_git_repo(BASE_DIR):
    _init = init_repo(BASE_DIR)
    if _init["initialized"]:
        st.toast("🔀 Git repository initialized!", icon="✅")

# ─────────────────────────────────────────────────────────────────────────────
# VERSION HISTORY view (full page, replaces chat)
# ─────────────────────────────────────────────────────────────────────────────

if st.session_state.show_history:
    st.subheader("📜 Version History")

    _hist_cloud = st.selectbox(
        "Filter by cloud",
        ["All", "aws", "gcp", "azure"],
        key="hist_cloud_filter",
    )
    _filter = _hist_cloud if _hist_cloud != "All" else None
    _commits = get_commit_history(BASE_DIR, max_count=30, cloud_filter=_filter)

    if not _commits:
        st.info("No commits found." + (" Try 'All' filter." if _filter else ""))
    else:
        for _c in _commits:
            _short_date = _c["date"][:16]
            with st.expander(f"`{_c['short_hash']}` — {_c['message'][:60]}  ·  {_c['author']}  ·  {_short_date}"):
                st.markdown(f"**Full message:** {_c['message']}")
                st.markdown(f"**Author:** {_c['author']}")
                st.markdown(f"**Date:** {_c['date']}")
                st.markdown(f"**Hash:** `{_c['hash']}`")

                if st.button(f"Show diff", key=f"diff_{_c['hash']}"):
                    _diff = get_file_diff(BASE_DIR, _c["hash"])
                    st.code(_diff[:3000], language="diff")

    st.stop()

# ─────────────────────────────────────────────────────────────────────────────
# Initialise bot
# ─────────────────────────────────────────────────────────────────────────────

try:
    bot = _get_or_create_bot()
except FileNotFoundError as _exc:
    st.error(str(_exc))
    st.code("npm install -g @anthropic-ai/claude-code", language="bash")
    st.caption("Install Claude Code via the command above, then reload.")
    st.stop()

cloud    = cloud_label.lower()
workflow = _WORKFLOW_KEYS[workflow_label]


def _autosave() -> None:
    if not st.session_state.session_id or not engineer.strip():
        return
    save_session(
        session_id=st.session_state.session_id,
        engineer=engineer.strip(),
        cloud=cloud,
        workflow=workflow,
        messages=st.session_state.messages,
        pending=st.session_state.pending,
        phase=st.session_state.phase,
        form_state=snapshot_form_state(st.session_state),
    )


# Auto-save on every rerun once there are messages
if st.session_state.messages:
    _autosave()

# Pre-fill Quick Form fields from the most recent matching session when cloud/workflow changes
_prefill_key = f"{cloud}_{workflow}"
if st.session_state["_last_prefill_key"] != _prefill_key:
    _prefill_match = next(
        (s for s in list_sessions()
         if s["cloud"] == cloud and s["workflow"] == workflow
         and s["session_id"] != st.session_state.session_id),
        None,
    )
    if _prefill_match:
        restore_form_state(st.session_state, _prefill_match.get("form_state", {}))
    st.session_state["_last_prefill_key"] = _prefill_key


if not st.session_state.messages:
    with st.spinner("Starting session…"):
        opening = bot.chat(
            f"Hello! My name is {engineer.strip()}. "
            f"I need help with {workflow_label} on {cloud_label}."
        )
    st.session_state.messages.append({"role": "assistant", "content": opening})

# ─────────────────────────────────────────────────────────────────────────────
# Layout
# ─────────────────────────────────────────────────────────────────────────────

if st.session_state.phase in ("preview", "git_commit", "pr_created", "saved"):
    chat_col, preview_col = st.columns([3, 2], gap="large")
else:
    chat_col    = st.container()
    preview_col = None

# ═════════════════════════════════════════════════════════════════════════════
# CHAT COLUMN
# ═════════════════════════════════════════════════════════════════════════════

with chat_col:
    st.subheader("💬 Conversation")

    for _msg in st.session_state.messages:
        _avatar = "🤖" if _msg["role"] == "assistant" else "🧑‍💻"
        with st.chat_message(_msg["role"], avatar=_avatar):
            st.markdown(_msg["content"])

    if st.session_state.phase == "chat":
        _chat_tab, _form_tab = st.tabs(["💬 Chat", "📋 Quick Form"])

        with _chat_tab:
            user_input = st.chat_input("Type your response here…")

            if user_input:
                st.session_state.messages.append({"role": "user", "content": user_input})

                with st.spinner("InfraBot is thinking…"):
                    reply = bot.chat(user_input)

                st.session_state.messages.append({"role": "assistant", "content": reply})

                if bot.last_render and bot.last_render.get("success"):
                    _check = bot.last_check or {}
                    st.session_state.pending = {
                        "resource_type": _check.get(
                            "resource_type",
                            _RESOURCE_TYPES.get((workflow, cloud), ""),
                        ),
                        "resource_name": _check.get("resource_name", ""),
                        "rendered":      bot.last_render["rendered"],
                        "output_file":   bot.last_render["output_file"],
                        "cloud":         cloud,
                    }
                    bot.last_render = None
                    st.session_state.phase = "preview"

                st.rerun()

        with _form_tab:
            _form_inputs = render_provisioning_form(cloud, workflow)

            if _form_inputs is not None:
                with st.spinner("Generating Terraform…"):
                    _render = bot._tool_render_template(workflow, cloud, _form_inputs)

                if _render.get("success"):
                    _resource_name = (
                        _form_inputs.get("hostname")
                        or _form_inputs.get("rule_name")
                        or _form_inputs.get("resource_name")
                        or ""
                    )
                    st.session_state.pending = {
                        "resource_type": _RESOURCE_TYPES.get((workflow, cloud), ""),
                        "resource_name": _resource_name,
                        "rendered":      _render["rendered"],
                        "output_file":   _render["output_file"],
                        "cloud":         cloud,
                    }
                    bot.last_render = None
                    st.session_state.phase = "preview"
                    st.rerun()
                else:
                    st.error(f"Template error: {_render.get('error', 'unknown')}")

    elif st.session_state.phase == "preview":
        st.info("👉 Review the generated Terraform in the panel on the right.")

    elif st.session_state.phase == "git_commit":
        st.warning("🔀 Creating branch and committing — fill in PR details on the right.")

    elif st.session_state.phase == "pr_created":
        st.success(f"🔗 PR created! Waiting for approval → [View PR]({st.session_state.pr_url})")

    elif st.session_state.phase == "saved":
        st.success("✅ Resource saved. Click **New Session** in the sidebar to provision another.")

# ═════════════════════════════════════════════════════════════════════════════
# RIGHT COLUMN — PREVIEW / GIT / PR / SAVED
# ═════════════════════════════════════════════════════════════════════════════

if preview_col is None:
    st.stop()

pending = st.session_state.pending or {}
tf_path = Path(pending.get("output_file", ""))

# ── PREVIEW ───────────────────────────────────────────────────────────────────
if st.session_state.phase == "preview":
    existing = parse_resources(tf_path) if tf_path.exists() else []

    with preview_col:
        st.subheader("📋 Review & Confirm")

        _folder = tf_path.parent.name if tf_path.parent != Path(".") else "?"
        with st.expander(
            f"Existing resources in `{_folder}/main.tf` ({len(existing)})",
            expanded=bool(existing),
        ):
            if existing:
                for _rtype, _rname in existing:
                    st.markdown(f"✅ `{_rtype}.{_rname}`")
            else:
                st.caption("No existing resources — this will be the first entry.")

        st.divider()

        st.markdown("**🆕 New resource to be added:**")
        st.code(pending["rendered"], language="hcl")

        if existing:
            st.success(
                f"🔒 {len(existing)} existing resource(s) will **NOT** be changed — append only."
            )

        st.divider()

        _btn1, _btn2 = st.columns(2)

        with _btn1:
            if st.button("✅ Confirm & Create PR", type="primary", use_container_width=True):
                _result = append_to_tf(
                    tf_path=tf_path,
                    content=pending["rendered"],
                    engineer=engineer.strip(),
                    cloud_provider=pending["cloud"],
                    resource_type=pending["resource_type"],
                    resource_name=pending["resource_name"],
                )
                st.session_state.save_result = _result
                st.session_state.phase = "git_commit"
                st.rerun()

        with _btn2:
            if st.button("❌ Cancel", use_container_width=True):
                with st.spinner("…"):
                    _cancel_reply = bot.chat(
                        "I'd like to cancel. Please confirm nothing was saved "
                        "and ask what I'd like to change."
                    )
                st.session_state.messages.append({"role": "user",      "content": "❌ Cancelled"})
                st.session_state.messages.append({"role": "assistant", "content": _cancel_reply})
                st.session_state.phase   = "chat"
                st.session_state.pending = None
                st.rerun()

# ── GIT COMMIT ────────────────────────────────────────────────────────────────
elif st.session_state.phase == "git_commit":
    with preview_col:
        st.subheader("🔀 Git Branch & PR")

        _save = st.session_state.save_result or {}
        if _save.get("success"):
            st.success(f"✅ Terraform saved: `{pending.get('resource_type')}.{pending.get('resource_name')}`")
        else:
            st.error(f"Save issue: {_save.get('message', 'unknown')}")

        st.divider()

        # ── Branch selection ──────────────────────────────────────────────────
        st.markdown("**🌿 Branch**")
        _branch_mode = st.radio(
            "branch_mode",
            ["🔀 Auto-generate", "📂 Use existing", "✏️ Custom name"],
            horizontal=True,
            label_visibility="collapsed",
            key="branch_mode_radio",
        )

        import re as _re, datetime as _dt
        _auto_name = (
            f"infra/{pending.get('cloud','aws')}/"
            + _re.sub(r"[^a-zA-Z0-9_-]", "_", pending.get("resource_name", "resource"))
            + "_" + _dt.datetime.now().strftime("%Y%m%d_%H%M%S")
        )

        if _branch_mode == "📂 Use existing":
            _all_branches = list_branches(BASE_DIR)
            _non_default  = [b for b in _all_branches if b not in ("main", "master")]
            _branch_opts  = _non_default if _non_default else _all_branches
            _sel_existing = st.selectbox("Select branch", _branch_opts, key="existing_branch_select")
            st.session_state.custom_branch_name = _sel_existing
            st.caption(f"Will commit to existing: `{_sel_existing}`")

        elif _branch_mode == "✏️ Custom name":
            _custom_val = st.text_input(
                "Branch name",
                value=st.session_state.custom_branch_name or f"infra/{pending.get('cloud','aws')}/",
                placeholder="infra/aws/my-feature",
                key="custom_branch_input",
            )
            st.session_state.custom_branch_name = _custom_val
            st.caption(f"Will create: `{_custom_val}`")

        else:
            st.caption(f"Will create: `{_auto_name}`")

        st.divider()

        st.session_state.environment = st.selectbox(
            "🌍 Environment",
            ["production", "staging", "development"],
            index=["production", "staging", "development"].index(
                st.session_state.environment
            ),
        )

        st.session_state.pr_notes = st.text_area(
            "📝 PR Description / Notes",
            value=st.session_state.pr_notes,
            placeholder="Why is this resource needed? Any special notes for reviewers...",
            height=100,
        )

        st.divider()

        _has_token  = bool(st.session_state.github_token.strip())
        _has_remote = has_remote(BASE_DIR)

        if not _has_remote:
            st.warning("⚠️ No GitHub remote configured. Add it in ⚙️ GitHub Settings in the sidebar.")
        if not _has_token:
            st.warning("⚠️ No GitHub token. Add it in ⚙️ GitHub Settings in the sidebar.")

        _ready = _has_token and _has_remote

        def _resolve_branch() -> dict:
            """Create/switch to the chosen branch and return {ok, branch, message}."""
            mode = st.session_state.get("branch_mode_radio", "🔀 Auto-generate")
            if mode == "📂 Use existing":
                sel = st.session_state.get("existing_branch_select") or st.session_state.custom_branch_name
                sw  = switch_branch(BASE_DIR, sel)
                return {"ok": sw["ok"], "branch": sel, "message": sw["message"]}
            elif mode == "✏️ Custom name":
                name = st.session_state.custom_branch_name.strip()
                return checkout_new_branch(BASE_DIR, name)
            else:
                return create_branch(
                    BASE_DIR,
                    cloud=pending.get("cloud", "aws"),
                    resource_type=pending.get("resource_type", ""),
                    resource_name=pending.get("resource_name", ""),
                    engineer=engineer.strip(),
                )

        _col1, _col2 = st.columns(2)

        with _col1:
            if st.button(
                "🚀 Create Branch, Commit & PR",
                type="primary",
                use_container_width=True,
                disabled=not _ready,
            ):
                with st.spinner("Setting up branch…"):
                    _branch = _resolve_branch()

                if not _branch["ok"]:
                    st.error(f"Branch failed: {_branch['message']}")
                    st.stop()

                st.session_state.git_branch = _branch["branch"]

                with st.spinner("Committing terraform files…"):
                    _commit = commit_terraform(
                        BASE_DIR,
                        cloud=pending.get("cloud", "aws"),
                        resource_type=pending.get("resource_type", ""),
                        resource_name=pending.get("resource_name", ""),
                        engineer=engineer.strip(),
                    )

                if not _commit["ok"]:
                    st.error(f"Commit failed: {_commit['message']}")
                    st.stop()

                st.session_state.git_commit_hash = _commit["commit_hash"]

                with st.spinner("Pushing to GitHub…"):
                    _push = push_branch(BASE_DIR, _branch["branch"])

                if not _push["ok"]:
                    st.error(f"Push failed: {_push['message']}")
                    st.stop()

                with st.spinner("Creating Pull Request…"):
                    _pr = create_pull_request(
                        BASE_DIR,
                        branch_name=_branch["branch"],
                        cloud=pending.get("cloud", "aws"),
                        resource_type=pending.get("resource_type", ""),
                        resource_name=pending.get("resource_name", ""),
                        engineer=engineer.strip(),
                        github_token=st.session_state.github_token.strip(),
                        environment=st.session_state.environment,
                        notes=st.session_state.pr_notes,
                    )

                if _pr["ok"]:
                    st.session_state.pr_url    = _pr["pr_url"]
                    st.session_state.pr_number = _pr["pr_number"]

                    log_git_action(
                        CHANGES_LOG, engineer.strip(), "pr_created",
                        f"branch={_branch['branch']} | pr=#{_pr['pr_number']} | "
                        f"resource={pending.get('resource_type')}.{pending.get('resource_name')}",
                    )

                    st.session_state.phase = "pr_created"
                    st.rerun()
                else:
                    st.error(f"PR creation failed: {_pr['message']}")

        with _col2:
            if st.button("⬅️ Back to Review", use_container_width=True):
                st.session_state.phase = "preview"
                st.rerun()

        # Local-only option if no remote/token
        if not _ready:
            st.divider()
            st.markdown("**Or commit locally only (no PR):**")
            if st.button("💾 Commit Locally", use_container_width=True):
                _branch = _resolve_branch()
                if _branch["ok"]:
                    _commit = commit_terraform(
                        BASE_DIR,
                        cloud=pending.get("cloud", "aws"),
                        resource_type=pending.get("resource_type", ""),
                        resource_name=pending.get("resource_name", ""),
                        engineer=engineer.strip(),
                    )
                    st.session_state.git_branch      = _branch["branch"]
                    st.session_state.git_commit_hash = _commit.get("commit_hash", "")

                    log_git_action(
                        CHANGES_LOG, engineer.strip(), "local_commit",
                        f"branch={_branch['branch']} | "
                        f"resource={pending.get('resource_type')}.{pending.get('resource_name')}",
                    )

                    st.session_state.phase = "saved"
                    st.rerun()

# ── PR CREATED ────────────────────────────────────────────────────────────────
elif st.session_state.phase == "pr_created":
    with preview_col:
        st.subheader("🔗 Pull Request Created")

        st.success("Your PR is live on GitHub!")

        st.markdown(f"""
| Detail | Value |
|--------|-------|
| **Branch** | `{st.session_state.git_branch}` |
| **Commit** | `{st.session_state.git_commit_hash}` |
| **PR** | #{st.session_state.pr_number} |
| **Resource** | `{pending.get('resource_type')}.{pending.get('resource_name')}` |
| **Cloud** | {pending.get('cloud', '?').upper()} |
| **Environment** | {st.session_state.environment} |
""")

        st.divider()

        st.markdown(f"### [🔗 Open PR on GitHub →]({st.session_state.pr_url})")
        st.caption("Share this link with your approver for review.")

        st.divider()

        if st.button("🔄 Check PR Status", use_container_width=True):
            with st.spinner("Checking…"):
                _status = get_pr_status(
                    BASE_DIR,
                    st.session_state.pr_number,
                    st.session_state.github_token.strip(),
                )

            if _status["ok"]:
                _state = _status["state"]
                if _state == "merged":
                    st.success("✅ PR has been **merged**! Deployment approved.")
                elif _status.get("approved"):
                    st.success("✅ PR has been **approved**! Ready to merge.")
                elif _status.get("changes_requested"):
                    st.warning("⚠️ **Changes requested** — check PR comments on GitHub.")
                elif _state == "open":
                    st.info(f"⏳ PR is still **open** — {_status['review_count']} review(s) so far.")
                elif _state == "closed":
                    st.error("❌ PR was **closed** without merging.")
            else:
                st.error(f"Could not check status: {_status['message']}")

        st.divider()

        _c1, _c2 = st.columns(2)

        with _c1:
            if st.button("✅ Done — New Session", type="primary", use_container_width=True):
                st.session_state.phase = "saved"
                st.rerun()

        with _c2:
            if st.button("❌ Cancel & Delete Branch", use_container_width=True):
                base = get_default_branch(BASE_DIR)
                switch_branch(BASE_DIR, base)
                log_git_action(
                    CHANGES_LOG, engineer.strip(), "cancelled",
                    f"branch={st.session_state.git_branch} | pr=#{st.session_state.pr_number}",
                )
                st.session_state.messages.append(
                    {"role": "assistant", "content": "❌ PR cancelled. Branch left on GitHub for cleanup. What would you like to do next?"}
                )
                st.session_state.phase   = "chat"
                st.session_state.pending = None
                st.rerun()

# ── SAVED ─────────────────────────────────────────────────────────────────────
elif st.session_state.phase == "saved":
    _result = st.session_state.save_result or {}

    with preview_col:
        st.subheader("📋 Deployment Summary")

        st.success("✅ Resource committed and PR created!")

        st.markdown(f"""
| Detail | Value |
|--------|-------|
| **Cloud** | {pending.get('cloud', '?').upper()} |
| **Resource** | `{pending.get('resource_type')}.{pending.get('resource_name')}` |
| **Branch** | `{st.session_state.git_branch}` |
| **Commit** | `{st.session_state.git_commit_hash}` |
| **Environment** | {st.session_state.environment} |
""")

        if st.session_state.pr_url:
            st.markdown(f"**PR:** [{st.session_state.pr_url}]({st.session_state.pr_url})")

        st.divider()

        if tf_path.exists():
            st.markdown("**⬇️ Download updated file:**")
            st.download_button(
                label=f"Download {tf_path.parent.name}/main.tf",
                data=tf_path.read_text(encoding="utf-8"),
                file_name="main.tf",
                mime="text/plain",
                use_container_width=True,
            )

        st.divider()

        st.markdown("**📝 Recent log entries:**")
        if CHANGES_LOG.exists():
            _lines = CHANGES_LOG.read_text(encoding="utf-8").strip().splitlines()
            _recent = _lines[-4:] if len(_lines) >= 4 else _lines
            for _line in _recent:
                st.code(_line, language="text")

        st.divider()

        if st.button("🔄 Start New Session", use_container_width=True):
            _reset()
            st.rerun()
