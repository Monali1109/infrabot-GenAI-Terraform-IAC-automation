# Ã¢ÂÂÃ¢ÂÂ Compute: gmol8d2bh (prod) Ã¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂ
variable "gmol8d2bh_machine_type" {
  description = "GCP machine type"
  type        = string
  default     = "n2-standard-2"
}
variable "gmol8d2bh_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}
variable "gmol8d2bh_disk_size" {
  description = "Boot disk size GB"
  type        = number
  default     = 50
}

resource "google_compute_instance" "gmol8d2bh" {
  count        = var.gmol8d2bh_count
  name         = "gmol8d2bh-${count.index}"
  machine_type = var.gmol8d2bh_machine_type
  zone         = "${var.gcp_region}-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = var.gmol8d2bh_disk_size
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
  labels = { environment = "prod", generation = "gmol8d2bh", name = "gmol8d2bh" }
}

output "gmol8d2bh_names"        { value = google_compute_instance.gmol8d2bh[*].name }
output "gmol8d2bh_internal_ips" { value = google_compute_instance.gmol8d2bh[*].network_interface[0].network_ip }