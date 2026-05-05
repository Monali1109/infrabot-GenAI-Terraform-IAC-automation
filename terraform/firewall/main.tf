resource "google_compute_firewall" "allow_https" {
  name    = "fw-gcp-test-allow-https"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["app-server"]
}

resource "google_compute_firewall" "allow_ssh_admin" {
  name    = "fw-gcp-test-allow-ssh"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [var.admin_cidr]
  target_tags   = ["app-server", "db-server"]
}

resource "google_compute_firewall" "allow_db_internal" {
  name    = "fw-gcp-test-allow-db"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_tags = ["app-server"]
  target_tags = ["db-server"]
}
