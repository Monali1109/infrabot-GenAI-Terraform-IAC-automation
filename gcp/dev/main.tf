# Ã¢ÂÂÃ¢ÂÂ IAM: gmolagv59 (dev) Ã¢ÂÂÃ¢ÂÂ Who: auto-SA  |  Access: project-wide
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