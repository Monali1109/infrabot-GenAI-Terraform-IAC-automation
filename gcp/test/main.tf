# ── Compute: gmolq40on (test) ─────────────────────────────────
variable "gmolq40on_machine_type" {
  description = "GCP machine type"
  type        = string
  default     = "n2-standard-2"
}
variable "gmolq40on_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}
variable "gmolq40on_disk_size" {
  description = "Boot disk size GB"
  type        = number
  default     = 50
}

resource "google_compute_instance" "gmolq40on" {
  count        = var.gmolq40on_count
  name         = "gmolq40on-${count.index}"
  machine_type = var.gmolq40on_machine_type
  zone         = "${var.gcp_region}-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = var.gmolq40on_disk_size
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
  labels = { environment = "test", generation = "gmolq40on", name = "gmolq40on" }
}

output "gmolq40on_names"        { value = google_compute_instance.gmolq40on[*].name }
output "gmolq40on_internal_ips" { value = google_compute_instance.gmolq40on[*].network_interface[0].network_ip }