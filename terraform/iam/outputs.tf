output "app_sa_email" {
  description = "App service account email"
  value       = google_service_account.app.email
}

output "db_sa_email" {
  description = "DB service account email"
  value       = google_service_account.db.email
}
