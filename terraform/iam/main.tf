resource "google_service_account" "app" {
  account_id   = "sa-gcp-app-dev"
  display_name = "App Service Account - DEV"
  description  = "Service account for app servers in dev"
}

resource "google_project_iam_member" "app_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.app.email}"
}

resource "google_project_iam_member" "app_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.app.email}"
}

resource "google_service_account" "db" {
  account_id   = "sa-gcp-db-dev"
  display_name = "DB Service Account - DEV"
  description  = "Service account for DB servers in dev"
}

resource "google_project_iam_member" "db_storage" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.db.email}"
}
