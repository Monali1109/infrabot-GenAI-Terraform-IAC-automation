output "gapptst01_private_ip" {
  description = "Private IP of GAPPTST01"
  value       = google_compute_instance.gapptst01.network_interface[0].network_ip
}

output "gapptst01_instance_id" {
  description = "Instance ID of GAPPTST01"
  value       = google_compute_instance.gapptst01.id
}

output "gdbtst01_private_ip" {
  description = "Private IP of GDBTST01"
  value       = google_compute_instance.gdbtst01.network_interface[0].network_ip
}

output "gdbtst01_instance_id" {
  description = "Instance ID of GDBTST01"
  value       = google_compute_instance.gdbtst01.id
}
