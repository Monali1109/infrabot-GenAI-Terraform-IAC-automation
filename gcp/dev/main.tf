# ── Firewall: gmojzqste (dev) ──────────────────────────────────
resource "google_compute_firewall" "gmojzqste_allow" {
  name      = "${var.project_name}-gmojzqste-allow"
  network   = var.vpc_network
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }

  # Source / destination
  source_ranges      = ["10.20.0.155/23"]
  destination_ranges = ["198.234.0.54"]
  target_tags        = ["web", "gmojzqste"]
  description        = "gmojzqste firewall in dev"
}

resource "google_compute_firewall" "gmojzqste_deny_default" {
  name      = "${var.project_name}-gmojzqste-deny"
  network   = var.vpc_network
  direction = "INGRESS"
  priority  = 65534
  deny { protocol = "all" }
  source_ranges = ["0.0.0.0/0"]
  description   = "Default deny — override with higher-priority rules"
}

output "gmojzqste_fw_name" { value = google_compute_firewall.gmojzqste_allow.name }