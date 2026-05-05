resource "google_secret_manager_secret" "db_password" {
  secret_id = "prod-database-password"

  replication {
    auto {}
  }

  labels = {
    environment = "prod"
    managed_by  = "terraform"
  }
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = var.db_password
}

resource "google_secret_manager_secret_iam_member" "app_access" {
  secret_id = google_secret_manager_secret.db_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.app_service_account}"
}

resource "google_kms_key_ring" "main" {
  name     = "kr-gcp-prod-01"
  location = var.region
}

resource "google_kms_crypto_key" "secrets" {
  name     = "ck-gcp-prod-secrets-01"
  key_ring = google_kms_key_ring.main.id

  rotation_period = "7776000s"

  labels = {
    environment = "prod"
    managed_by  = "terraform"
  }
}
