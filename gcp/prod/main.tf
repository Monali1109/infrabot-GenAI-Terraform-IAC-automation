# ── Compute: gmoslz2li (prod) ─────────────────────────────────
variable "gmoslz2li_machine_type" {
  description = "GCP machine type"
  type        = string
  default     = "n2-highmem-4"
}
variable "gmoslz2li_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}
variable "gmoslz2li_disk_size" {
  description = "Boot disk size GB"
  type        = number
  default     = 100
}

resource "google_compute_instance" "gmoslz2li" {
  count        = var.gmoslz2li_count
  name         = "Myfistserv1-${count.index}"
  machine_type = var.gmoslz2li_machine_type
  zone         = "${var.gcp_region}-a"

  boot_disk {
    initialize_params {
      image = "windows-cloud/windows-2022"
      size  = var.gmoslz2li_disk_size
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
    source      = google_compute_disk.gmoslz2li_disk_d.self_link
    device_name = "disk-d"
    mode        = "READ_WRITE"
  }
  attached_disk {
    source      = google_compute_disk.gmoslz2li_disk_e.self_link
    device_name = "disk-e"
    mode        = "READ_WRITE"
  }
  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
  labels = { environment = "prod", generation = "gmoslz2li", name = "Myfistserv1", granted_user = "tester", granted_role = "administrator" }
}

resource "google_compute_disk" "gmoslz2li_disk_d" {
  name = "Myfistserv1-gmoslz2li-disk-d"
  type = "pd-ssd"
  zone = "${var.gcp_region}-a"
  size = 40
  labels = { environment = "prod", drive = "drive-d" }
}
resource "google_compute_disk" "gmoslz2li_disk_e" {
  name = "Myfistserv1-gmoslz2li-disk-e"
  type = "pd-ssd"
  zone = "${var.gcp_region}-a"
  size = 76
  labels = { environment = "prod", drive = "drive-e" }
}
output "gmoslz2li_names"        { value = google_compute_instance.gmoslz2li[*].name }
output "gmoslz2li_internal_ips" { value = google_compute_instance.gmoslz2li[*].network_interface[0].network_ip }