resource "google_compute_instance" "gapptst01" {
  name         = "gapptst01"
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
    network_ip = "10.30.1.10"
  }

  labels = {
    name        = "gapptst01"
    environment = "test"
    role        = "app"
    managed_by  = "terraform"
  }
}

resource "google_compute_instance" "gdbtst01" {
  name         = "gdbtst01"
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
    network_ip = "10.30.2.11"
  }

  labels = {
    name        = "gdbtst01"
    environment = "test"
    role        = "db"
    managed_by  = "terraform"
  }
}
