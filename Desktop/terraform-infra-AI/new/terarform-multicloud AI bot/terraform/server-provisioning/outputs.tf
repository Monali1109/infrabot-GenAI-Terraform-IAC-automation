output "gapppd01_private_ip" {
  description = "Private IP of GAPPPD01"
  value       = google_compute_instance.gapppd01.network_interface[0].network_ip
}

output "gapppd01_instance_id" {
  description = "Instance ID of GAPPPD01"
  value       = google_compute_instance.gapppd01.id
}

output "gdbpd01_private_ip" {
  description = "Private IP of GDBPD01"
  value       = google_compute_instance.gdbpd01.network_interface[0].network_ip
}

output "gdbpd01_instance_id" {
  description = "Instance ID of GDBPD01"
  value       = google_compute_instance.gdbpd01.id
}
