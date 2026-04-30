# ── IAM: gmolarkas (prod) ── Who: monali11dpatil@gmail.com  |  Access: project-wide

# Project-level IAM
resource "google_project_iam_member" "gmolarkas_binding" {
  project = var.gcp_project_id
  role    = "roles/viewer"
  member  = "user:monali11dpatil@gmail.com"
}


output "gmolarkas_member" { value = "user:monali11dpatil@gmail.com" }