output "app_disk_id" {
  description = "App disk ID"
  value       = google_compute_disk.app_data.id
}

output "db_disk_id" {
  description = "DB disk ID"
  value       = google_compute_disk.db_data.id
}
