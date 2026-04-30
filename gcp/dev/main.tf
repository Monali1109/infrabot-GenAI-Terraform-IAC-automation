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

# ── IAM: gmolagv59 (dev) ── Who: auto-SA  |  Access: project-wide
resource "google_service_account" "gmolagv59_sa" {
  account_id   = "${var.project_name}-gmolagv59-sa"
  display_name = "gmolagv59 SA (dev)"
  project      = var.gcp_project_id
}

# Project-level IAM
resource "google_project_iam_member" "gmolagv59_binding" {
  project = var.gcp_project_id
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.gmolagv59_sa.email}"
}

output "gmolagv59_sa_email" { value = google_service_account.gmolagv59_sa.email }
output "gmolagv59_member" { value = "serviceAccount:${google_service_account.gmolagv59_sa.email}" }