resource "google_compute_instance" "gapppd01" {
  name         = "gapppd01"
  machine_type = "n2-custom-4-8192"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 50
    }
  }

  network_interface {
    subnetwork = var.subnetwork
    network_ip = "10.10.1.10"
  }

  labels = {
    name        = "gapppd01"
    environment = "prod"
    role        = "app"
    managed_by  = "terraform"
  }
}

resource "google_compute_instance" "gdbpd01" {
  name         = "gdbpd01"
  machine_type = "n2-standard-8"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 100
    }
  }

  network_interface {
    subnetwork = var.subnetwork
    network_ip = "10.10.2.11"
  }

  labels = {
    name        = "gdbpd01"
    environment = "prod"
    role        = "db"
    managed_by  = "terraform"
  }
}
