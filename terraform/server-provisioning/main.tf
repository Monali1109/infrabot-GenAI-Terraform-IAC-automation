resource "google_compute_instance" "gappdv01" {
  name         = "gappdv01"
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
    network_ip = "10.20.1.10"
  }

  labels = {
    name        = "gappdv01"
    environment = "dev"
    role        = "app"
    managed_by  = "terraform"
  }
}

resource "google_compute_instance" "gdbdv01" {
  name         = "gdbdv01"
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
    network_ip = "10.20.2.11"
  }

  labels = {
    name        = "gdbdv01"
    environment = "dev"
    role        = "db"
    managed_by  = "terraform"
  }
}
