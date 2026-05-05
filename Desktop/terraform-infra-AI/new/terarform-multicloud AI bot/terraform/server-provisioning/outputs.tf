output "gappdv01_private_ip" {
  description = "Private IP of GAPPDV01"
  value       = google_compute_instance.gappdv01.network_interface[0].network_ip
}

output "gappdv01_instance_id" {
  description = "Instance ID of GAPPDV01"
  value       = google_compute_instance.gappdv01.id
}

output "gdbdv01_private_ip" {
  description = "Private IP of GDBDV01"
  value       = google_compute_instance.gdbdv01.network_interface[0].network_ip
}

output "gdbdv01_instance_id" {
  description = "Instance ID of GDBDV01"
  value       = google_compute_instance.gdbdv01.id
}
