import { useState } from "react";

const envOptions = ["production", "staging", "development"];

const inputStyle = {
  width: "100%", padding: "7px 10px",
  border: "0.5px solid var(--color-border-secondary)",
  borderRadius: "var(--border-radius-md)",
  background: "var(--color-background-primary)",
  color: "var(--color-text-primary)",
  fontFamily: "var(--font-mono)",
  fontSize: 13,
};

const btnBase = {
  padding: "9px 16px",
  background: "var(--color-background-primary)",
  border: "0.5px solid var(--color-border-secondary)",
  borderRadius: "var(--border-radius-md)",
  color: "var(--color-text-primary)",
  fontSize: 13,
  fontFamily: "var(--font-sans)",
  cursor: "pointer",
  display: "flex",
  alignItems: "center",
  justifyContent: "center",
  gap: 7,
};

function Section({ label, children }) {
  return (
    <div style={{ background: "var(--color-background-primary)", border: "0.5px solid var(--color-border-tertiary)", borderRadius: "var(--border-radius-lg)", padding: "1rem 1.25rem", marginBottom: 12 }}>
      <div style={{ fontSize: 11, fontFamily: "var(--font-mono)", color: "var(--color-text-tertiary)", letterSpacing: "0.08em", textTransform: "uppercase", marginBottom: 12 }}>{label}</div>
      {children}
    </div>
  );
}

function Field({ label, children, style }) {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 5, ...style }}>
      <label style={{ fontSize: 11, fontFamily: "var(--font-mono)", color: "var(--color-text-secondary)", letterSpacing: "0.04em" }}>{label}</label>
      {children}
    </div>
  );
}

function buildHtmlEmail(form) {
  const approveSubject = encodeURIComponent(`APPROVED: Terraform Deployment — ${form.instance_name} (${form.environment})`);
  const approveBody = encodeURIComponent(`DECISION: APPROVED\n\nI approve this deployment to proceed.\n\n  Instance Name : ${form.instance_name}\n  GCP Project   : ${form.project_id}\n  Environment   : ${form.environment.toUpperCase()}\n\nApproved by: [Your Name]\nDate: [Today's Date]`);
  const rejectSubject = encodeURIComponent(`REJECTED: Terraform Deployment — ${form.instance_name} (${form.environment})`);
  const rejectBody = encodeURIComponent(`DECISION: REJECTED\n\nREJECTION REASON (mandatory — do not leave blank):\n-----------------------------------------------\n[Please write your comments here]\n-----------------------------------------------\n\n  Instance Name : ${form.instance_name}\n  GCP Project   : ${form.project_id}\n  Environment   : ${form.environment.toUpperCase()}\n\nRejected by: [Your Name]\nDate: [Today's Date]`);

  const replyTo = form.from_email || "requester@deloitte.com";
  const approveHref = `mailto:${replyTo}?subject=${approveSubject}&body=${approveBody}`;
  const rejectHref  = `mailto:${replyTo}?subject=${rejectSubject}&body=${rejectBody}`;

  const envColor = form.environment === "production" ? "#c0392b" : form.environment === "staging" ? "#b7770d" : "#1a6eb5";
  const envBg    = form.environment === "production" ? "#fff0f0" : form.environment === "staging" ? "#fff8e6" : "#f0f7ff";

  return `<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"></head>
<body style="margin:0;padding:0;background:#f0f2f5;font-family:'Segoe UI',Arial,sans-serif;">
<table width="100%" cellpadding="0" cellspacing="0" style="background:#f0f2f5;padding:32px 0;">
  <tr><td align="center">
    <table width="580" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:10px;overflow:hidden;border:1px solid #dde1e7;">

      <!-- Header -->
      <tr>
        <td style="background:#002147;padding:30px 36px 24px;">
          <p style="margin:0 0 4px;font-size:10px;color:#6a9fd8;letter-spacing:2.5px;text-transform:uppercase;font-weight:600;">Deloitte &bull; Infrastructure Automation</p>
          <h1 style="margin:0;font-size:24px;color:#ffffff;font-weight:600;line-height:1.3;">Deployment Approval Request</h1>
        </td>
      </tr>

      <!-- Body -->
      <tr><td style="padding:32px 36px 0;">
        <p style="margin:0 0 24px;font-size:15px;color:#444;line-height:1.7;">
          Dear Approver, a GCP infrastructure deployment requires your review and sign-off before it can proceed.
        </p>

        <!-- Details Card -->
        <table width="100%" cellpadding="0" cellspacing="0" style="background:#f8f9fb;border-radius:8px;border:1px solid #e4e7ec;margin-bottom:28px;">
          <tr><td style="padding:14px 20px 10px;">
            <p style="margin:0 0 12px;font-size:10px;font-weight:700;color:#999;letter-spacing:2px;text-transform:uppercase;">Deployment Details</p>
            <table width="100%" cellpadding="0" cellspacing="0">
              <tr>
                <td style="padding:5px 0;font-size:12px;color:#999;font-family:monospace;width:130px;">instance_name</td>
                <td style="padding:5px 0;font-size:13px;color:#111;font-weight:700;font-family:monospace;">${form.instance_name || "—"}</td>
              </tr>
              <tr>
                <td style="padding:5px 0;font-size:12px;color:#999;font-family:monospace;">project_id</td>
                <td style="padding:5px 0;font-size:13px;color:#111;font-weight:700;font-family:monospace;">${form.project_id || "—"}</td>
              </tr>
              <tr>
                <td style="padding:5px 0;font-size:12px;color:#999;font-family:monospace;">zone</td>
                <td style="padding:5px 0;font-size:13px;color:#111;font-weight:700;font-family:monospace;">${form.zone || "—"}</td>
              </tr>
              <tr>
                <td style="padding:5px 0;font-size:12px;color:#999;font-family:monospace;">machine_type</td>
                <td style="padding:5px 0;font-size:13px;color:#111;font-weight:700;font-family:monospace;">${form.machine_type || "—"}</td>
              </tr>
              <tr>
                <td style="padding:5px 0;font-size:12px;color:#999;font-family:monospace;">environment</td>
                <td style="padding:5px 0;">
                  <span style="background:${envBg};color:${envColor};font-size:11px;font-weight:700;letter-spacing:1px;text-transform:uppercase;padding:3px 10px;border-radius:4px;font-family:monospace;">${form.environment}</span>
                </td>
              </tr>
            </table>
          </td></tr>
        </table>

        <!-- Terraform Commands -->
        <table width="100%" cellpadding="0" cellspacing="0" style="background:#1a1b2e;border-radius:8px;margin-bottom:28px;">
          <tr><td style="padding:12px 18px 4px;font-size:10px;color:#666;letter-spacing:2px;text-transform:uppercase;font-weight:600;">Commands to be executed</td></tr>
          <tr><td style="padding:4px 18px 16px;font-family:'Courier New',monospace;font-size:13px;line-height:2.2;color:#cdd6f4;">
            <span style="color:#89dceb;">cd</span> output/gcp<br>
            <span style="color:#a6e3a1;">terraform</span> init<br>
            <span style="color:#a6e3a1;">terraform</span> plan<br>
            <span style="color:#a6e3a1;">terraform</span> apply
          </td></tr>
        </table>

        ${form.notes ? `<table width="100%" cellpadding="0" cellspacing="0" style="background:#fffbf0;border-left:4px solid #f5a623;border-radius:0 6px 6px 0;margin-bottom:28px;"><tr><td style="padding:12px 16px;font-size:13px;color:#555;line-height:1.6;"><strong style="color:#333;">Notes: </strong>${form.notes}</td></tr></table>` : ""}

        <table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom:10px;">
          <tr><td style="border-top:1px solid #eee;"></td></tr>
        </table>

        <p style="margin:20px 0 22px;font-size:14px;color:#222;font-weight:600;text-align:center;letter-spacing:0.2px;">Please respond to this deployment request:</p>

        <!-- BUTTONS -->
        <table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom:16px;">
          <tr>
            <td width="46%" align="center">
              <a href="${approveHref}"
                style="display:inline-block;background:#1a7f4e;color:#ffffff;text-decoration:none;font-size:16px;font-weight:700;padding:16px 0;border-radius:8px;font-family:'Segoe UI',Arial,sans-serif;letter-spacing:0.4px;width:220px;text-align:center;">
                &#10003;&nbsp; Approve
              </a>
            </td>
            <td width="8%"></td>
            <td width="46%" align="center">
              <a href="${rejectHref}"
                style="display:inline-block;background:#c0392b;color:#ffffff;text-decoration:none;font-size:16px;font-weight:700;padding:16px 0;border-radius:8px;font-family:'Segoe UI',Arial,sans-serif;letter-spacing:0.4px;width:220px;text-align:center;">
                &#10007;&nbsp; Reject
              </a>
            </td>
          </tr>
        </table>

        <p style="margin:0 0 28px;font-size:12px;color:#e74c3c;text-align:center;font-weight:500;">
          &#9888; Rejection requires mandatory comments &mdash; blank rejections will not be accepted.
        </p>
      </td></tr>

      <!-- Footer -->
      <tr>
        <td style="background:#f8f9fb;border-top:1px solid #e4e7ec;padding:16px 36px;">
          <p style="margin:0;font-size:12px;color:#aaa;line-height:1.6;">
            Requested by <strong style="color:#777;">${form.from_name || "Requester"}</strong> &bull; Deloitte Infrastructure Automation &bull; Do not forward this email.
          </p>
        </td>
      </tr>

    </table>
  </td></tr>
</table>
</body>
</html>`;
}

export default function App() {
  const [form, setForm] = useState({
    instance_name: "", zone: "", machine_type: "", project_id: "",
    environment: "production", notes: "",
    to: "", cc: "", from_name: "", from_email: "",
  });
  const [downloaded, setDownloaded] = useState(false);
  const [copied, setCopied] = useState(false);
  const [preview, setPreview] = useState(false);

  const set = (k, v) => setForm(f => ({ ...f, [k]: v }));
  const isReady = form.to && form.instance_name && form.zone && form.machine_type && form.project_id && form.from_email;

  const handleDownload = () => {
    const html = buildHtmlEmail(form);
    const blob = new Blob([html], { type: "text/html" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `approval-${form.instance_name || "deployment"}.html`;
    a.click();
    URL.revokeObjectURL(url);
    setDownloaded(true);
    setTimeout(() => setDownloaded(false), 3000);
  };

  const handleCopyHtml = () => {
    navigator.clipboard.writeText(buildHtmlEmail(form));
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div style={{ padding: "1.5rem 0", fontFamily: "var(--font-sans)" }}>
      <h2 className="sr-only">Terraform GCP Deployment Approval Email Sender</h2>

      <div style={{ display: "flex", alignItems: "flex-start", justifyContent: "space-between", marginBottom: "1.5rem" }}>
        <div>
          <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 4 }}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" style={{ color: "var(--color-text-secondary)" }}><rect x="2" y="4" width="20" height="16" rx="2"/><polyline points="2,4 12,13 22,4"/></svg>
            <span style={{ fontSize: 16, fontWeight: 500, color: "var(--color-text-primary)" }}>Deployment Approval Mailer</span>
          </div>
          <span style={{ fontSize: 13, color: "var(--color-text-secondary)" }}>HTML email with Approve / Reject buttons — paste into Outlook</span>
        </div>
        <span style={{ fontSize: 11, fontFamily: "var(--font-mono)", background: "var(--color-background-success)", color: "var(--color-text-success)", padding: "3px 8px", borderRadius: 4, whiteSpace: "nowrap" }}>● Outlook HTML</span>
      </div>

      <Section label="deployment info">
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10 }}>
          {[{ id: "instance_name", ph: "prod-web-01" }, { id: "project_id", ph: "my-gcp-project" }, { id: "zone", ph: "us-central1-a" }, { id: "machine_type", ph: "n1-standard-2" }].map(f => (
            <Field key={f.id} label={f.id}>
              <input value={form[f.id]} onChange={e => set(f.id, e.target.value)} placeholder={f.ph} style={inputStyle} />
            </Field>
          ))}
          <Field label="environment">
            <select value={form.environment} onChange={e => set("environment", e.target.value)} style={inputStyle}>
              {envOptions.map(o => <option key={o} value={o}>{o}</option>)}
            </select>
          </Field>
        </div>
        <Field label="notes (optional)" style={{ marginTop: 10 }}>
          <textarea value={form.notes} onChange={e => set("notes", e.target.value)} placeholder="Any context for the approver..." rows={2} style={{ ...inputStyle, resize: "vertical" }} />
        </Field>
      </Section>

      <Section label="recipients & sender">
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10 }}>
          <Field label="to — approver email">
            <input value={form.to} onChange={e => set("to", e.target.value)} placeholder="approver@deloitte.com" style={inputStyle} />
          </Field>
          <Field label="cc (optional)">
            <input value={form.cc} onChange={e => set("cc", e.target.value)} placeholder="team@deloitte.com" style={inputStyle} />
          </Field>
          <Field label="your name">
            <input value={form.from_name} onChange={e => set("from_name", e.target.value)} placeholder="Your Name" style={inputStyle} />
          </Field>
          <Field label="your email (approve/reject replies go here)">
            <input value={form.from_email} onChange={e => set("from_email", e.target.value)} placeholder="you@deloitte.com" style={inputStyle} />
          </Field>
        </div>
      </Section>

      <div style={{ background: "var(--color-background-info)", border: "0.5px solid var(--color-border-info)", borderRadius: "var(--border-radius-md)", padding: "10px 14px", marginBottom: 12, fontSize: 12, color: "var(--color-text-info)", fontFamily: "var(--font-mono)", lineHeight: 1.8 }}>
        <strong>How to send via Outlook:</strong><br />
        1. Click "Download HTML" → open the file in your browser (Chrome/Edge)<br />
        2. Select all (Ctrl+A) → Copy (Ctrl+C)<br />
        3. In Outlook new email → paste into body → add To/CC → Send
      </div>

      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 10 }}>
        <button onClick={() => setPreview(p => !p)} style={btnBase}>
          <EyeIcon /> {preview ? "hide preview" : "preview email"}
        </button>
        <button onClick={handleCopyHtml} style={btnBase}>
          <CopyIcon /> {copied ? "copied!" : "copy HTML"}
        </button>
        <button onClick={handleDownload} disabled={!isReady} style={{ ...btnBase, opacity: isReady ? 1 : 0.45, cursor: isReady ? "pointer" : "not-allowed" }}>
          <DownloadIcon /> {downloaded ? "downloaded!" : "download HTML"}
        </button>
      </div>

      {!isReady && (
        <p style={{ fontSize: 12, color: "var(--color-text-tertiary)", fontFamily: "var(--font-mono)", marginTop: 8, textAlign: "center" }}>
          fill in all deployment fields + both emails to enable download
        </p>
      )}

      {preview && (
        <div style={{ marginTop: 16, border: "0.5px solid var(--color-border-tertiary)", borderRadius: "var(--border-radius-lg)", overflow: "hidden" }}>
          <div style={{ padding: "8px 14px", background: "var(--color-background-secondary)", borderBottom: "0.5px solid var(--color-border-tertiary)", fontSize: 11, fontFamily: "var(--font-mono)", color: "var(--color-text-tertiary)", letterSpacing: "0.06em" }}>
            EMAIL PREVIEW — live render
          </div>
          <iframe srcDoc={buildHtmlEmail(form)} style={{ width: "100%", height: 640, border: "none", display: "block" }} title="Email Preview" />
        </div>
      )}
    </div>
  );
}

function EyeIcon() { return <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>; }
function CopyIcon() { return <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>; }
function DownloadIcon() { return <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>; }
