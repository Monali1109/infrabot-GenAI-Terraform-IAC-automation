output "network_id" {
  description = "VPC network ID"
  value       = google_compute_network.main.id
}

output "app_subnet_id" {
  description = "App subnetwork ID"
  value       = google_compute_subnetwork.app.id
}

output "db_subnet_id" {
  description = "DB subnetwork ID"
  value       = google_compute_subnetwork.db.id
}
