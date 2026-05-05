resource "google_service_account" "app" {
  account_id   = "sa-gcp-app-prod"
  display_name = "App Service Account - PROD"
  description  = "Service account for app servers in prod"
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
  account_id   = "sa-gcp-db-prod"
  display_name = "DB Service Account - PROD"
  description  = "Service account for DB servers in prod"
}

resource "google_project_iam_member" "db_storage" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.db.email}"
}
