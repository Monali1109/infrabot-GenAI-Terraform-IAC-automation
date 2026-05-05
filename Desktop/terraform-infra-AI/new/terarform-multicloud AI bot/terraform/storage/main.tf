resource "google_compute_disk" "app_data" {
  name  = "disk-gcp-app-prod-01"
  type  = "pd-ssd"
  zone  = var.zone
  size  = 100

  labels = {
    environment = "prod"
    role        = "app"
    managed_by  = "terraform"
  }
}

resource "google_compute_disk" "db_data" {
  name  = "disk-gcp-db-prod-01"
  type  = "pd-ssd"
  zone  = var.zone
  size  = 500

  labels = {
    environment = "prod"
    role        = "db"
    managed_by  = "terraform"
  }
}
