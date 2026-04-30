# ── Firewall: gmojzqste (dev) ──────────────────────────────────
resource "google_compute_firewall" "gmojzqste_allow" {
  name      = "${var.project_name}-gmojzqste-allow"
  network   = var.vpc_network
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }

  # Source / destination
  source_ranges      = ["10.20.0.155/23"]
  destination_ranges = ["198.234.0.54"]
  target_tags        = ["web", "gmojzqste"]
  description        = "gmojzqste firewall in dev"
}

resource "google_compute_firewall" "gmojzqste_deny_default" {
  name      = "${var.project_name}-gmojzqste-deny"
  network   = var.vpc_network
  direction = "INGRESS"
  priority  = 65534
  deny { protocol = "all" }
  source_ranges = ["0.0.0.0/0"]
  description   = "Default deny — override with higher-priority rules"
}

output "gmojzqste_fw_name" { value = google_compute_firewall.gmojzqste_allow.name }

# ── Compute: gmolq40on (dev) ─────────────────────────────────
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
  labels = { environment = "dev", generation = "gmolq40on", name = "gmolq40on" }
}

output "gmolq40on_names"        { value = google_compute_instance.gmolq40on[*].name }
output "gmolq40on_internal_ips" { value = google_compute_instance.gmolq40on[*].network_interface[0].network_ip }