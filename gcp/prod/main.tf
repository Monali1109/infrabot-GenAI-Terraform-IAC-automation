# ── Compute: gmol7xbze (prod) ─────────────────────────────────
variable "gmol7xbze_machine_type" {
  description = "GCP machine type"
  type        = string
  default     = "n2-standard-2"
}
variable "gmol7xbze_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}
variable "gmol7xbze_disk_size" {
  description = "Boot disk size GB"
  type        = number
  default     = 50
}

resource "google_compute_instance" "gmol7xbze" {
  count        = var.gmol7xbze_count
  name         = "gmol7xbze-${count.index}"
  machine_type = var.gmol7xbze_machine_type
  zone         = "${var.gcp_region}-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = var.gmol7xbze_disk_size
      type  = "pd-ssd"
    }
  }
  network_interface {
    network    = "var.vpc_network"
    subnetwork = "var.subnet_name"
    access_config {}
  }
  metadata = {
    enable-oslogin = "TRUE"
  }
  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
  labels = { environment = "prod", generation = "gmol7xbze", name = "gmol7xbze" }
}

output "gmol7xbze_names"        { value = google_compute_instance.gmol7xbze[*].name }
output "gmol7xbze_internal_ips" { value = google_compute_instance.gmol7xbze[*].network_interface[0].network_ip }