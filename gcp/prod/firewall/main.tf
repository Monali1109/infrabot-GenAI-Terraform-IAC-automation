# ── Firewall: gmoslipl7 (prod) ──────────────────────────────────
resource "google_compute_firewall" "gmoslipl7_allow" {
  name      = "${var.project_name}-gmoslipl7-allow"
  network   = var.vpc_network
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  # Source / destination
  source_ranges      = ["0.0.0.0/0"]
  destination_ranges = ["0.0.0.0/0"]
  target_tags        = ["web", "gmoslipl7"]
  description        = "gmoslipl7 firewall in prod"
}

resource "google_compute_firewall" "gmoslipl7_deny_default" {
  name      = "${var.project_name}-gmoslipl7-deny"
  network   = var.vpc_network
  direction = "INGRESS"
  priority  = 65534
  deny { protocol = "all" }
  source_ranges = ["0.0.0.0/0"]
  description   = "Default deny — override with higher-priority rules"
}

output "gmoslipl7_fw_name" { value = google_compute_firewall.gmoslipl7_allow.name }