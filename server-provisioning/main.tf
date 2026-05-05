# ── Compute: gmosv4v12 (prod) ─────────────────────────────────
variable "gmosv4v12_machine_type" {
  description = "GCP machine type"
  type        = string
  default     = "n4-standard-8"
}
variable "gmosv4v12_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}
variable "gmosv4v12_disk_size" {
  description = "Boot disk size GB"
  type        = number
  default     = 100
}

resource "google_compute_instance" "gmosv4v12" {
  count        = var.gmosv4v12_count
  name         = "GCPAPPPD02-${count.index}"
  machine_type = var.gmosv4v12_machine_type
  zone         = "${var.gcp_region}-a"

  boot_disk {
    initialize_params {
      image = "windows-cloud/windows-2022"
      size  = var.gmosv4v12_disk_size
      type  = "pd-ssd"
    }
  }
  network_interface {
    network    = ""vpc-0a1b2c3d4e5f67890""
    subnetwork = ""subnet-0abc1234def567890""
    access_config {}
  }
  metadata = {
    enable-oslogin = "TRUE"
  }
  attached_disk {
    source      = google_compute_disk.gmosv4v12_disk_d.self_link
    device_name = "disk-d"
    mode        = "READ_WRITE"
  }
  attached_disk {
    source      = google_compute_disk.gmosv4v12_disk_e.self_link
    device_name = "disk-e"
    mode        = "READ_WRITE"
  }
  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
  labels = { environment = "prod", generation = "gmosv4v12", name = "GCPAPPPD02", granted_user = "tester", granted_role = "administrator" }
}

resource "google_compute_disk" "gmosv4v12_disk_d" {
  name = "GCPAPPPD02-gmosv4v12-disk-d"
  type = "pd-ssd"
  zone = "${var.gcp_region}-a"
  size = 40
  labels = { environment = "prod", drive = "drive-d" }
}
resource "google_compute_disk" "gmosv4v12_disk_e" {
  name = "GCPAPPPD02-gmosv4v12-disk-e"
  type = "pd-ssd"
  zone = "${var.gcp_region}-a"
  size = 76
  labels = { environment = "prod", drive = "drive-e" }
}
output "gmosv4v12_names"        { value = google_compute_instance.gmosv4v12[*].name }
output "gmosv4v12_internal_ips" { value = google_compute_instance.gmosv4v12[*].network_interface[0].network_ip }

# ─── Appended 5/5/2026, 10:19:11 PM (gmosv58v6) ───

# ── Compute: gmosv58v6 (prod) ─────────────────────────────────
variable "gmosv58v6_machine_type" {
  description = "GCP machine type"
  type        = string
  default     = "n4-standard-8"
}
variable "gmosv58v6_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}
variable "gmosv58v6_disk_size" {
  description = "Boot disk size GB"
  type        = number
  default     = 100
}

resource "google_compute_instance" "gmosv58v6" {
  count        = var.gmosv58v6_count
  name         = "GCPAPPPD02-${count.index}"
  machine_type = var.gmosv58v6_machine_type
  zone         = "${var.gcp_region}-a"

  boot_disk {
    initialize_params {
      image = "windows-cloud/windows-2022"
      size  = var.gmosv58v6_disk_size
      type  = "pd-ssd"
    }
  }
  network_interface {
    network    = ""vpc-0a1b2c3d4e5f67890""
    subnetwork = ""subnet-0abc1234def567890""
    access_config {}
  }
  metadata = {
    enable-oslogin = "TRUE"
  }
  attached_disk {
    source      = google_compute_disk.gmosv58v6_disk_d.self_link
    device_name = "disk-d"
    mode        = "READ_WRITE"
  }
  attached_disk {
    source      = google_compute_disk.gmosv58v6_disk_e.self_link
    device_name = "disk-e"
    mode        = "READ_WRITE"
  }
  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
  labels = { environment = "prod", generation = "gmosv58v6", name = "GCPAPPPD02", granted_user = "tester", granted_role = "administrator" }
}

resource "google_compute_disk" "gmosv58v6_disk_d" {
  name = "GCPAPPPD02-gmosv58v6-disk-d"
  type = "pd-ssd"
  zone = "${var.gcp_region}-a"
  size = 40
  labels = { environment = "prod", drive = "drive-d" }
}
resource "google_compute_disk" "gmosv58v6_disk_e" {
  name = "GCPAPPPD02-gmosv58v6-disk-e"
  type = "pd-ssd"
  zone = "${var.gcp_region}-a"
  size = 76
  labels = { environment = "prod", drive = "drive-e" }
}
output "gmosv58v6_names"        { value = google_compute_instance.gmosv58v6[*].name }
output "gmosv58v6_internal_ips" { value = google_compute_instance.gmosv58v6[*].network_interface[0].network_ip }