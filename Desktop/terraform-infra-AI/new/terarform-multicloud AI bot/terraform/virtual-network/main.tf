resource "google_compute_network" "main" {
  name                    = "vpc-gcp-dev-01"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "app" {
  name          = "subnet-gcp-app-dev-01"
  ip_cidr_range = "10.20.1.0/24"
  region        = var.region
  network       = google_compute_network.main.id
}

resource "google_compute_subnetwork" "db" {
  name          = "subnet-gcp-db-dev-01"
  ip_cidr_range = "10.20.2.0/24"
  region        = var.region
  network       = google_compute_network.main.id
}
