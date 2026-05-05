resource "google_compute_disk" "app_data" {
  name  = "disk-gcp-app-dev-01"
  type  = "pd-ssd"
  zone  = var.zone
  size  = 100

  labels = {
    environment = "dev"
    role        = "app"
    managed_by  = "terraform"
  }
}

resource "google_compute_disk" "db_data" {
  name  = "disk-gcp-db-dev-01"
  type  = "pd-ssd"
  zone  = var.zone
  size  = 500

  labels = {
    environment = "dev"
    role        = "db"
    managed_by  = "terraform"
  }
}
