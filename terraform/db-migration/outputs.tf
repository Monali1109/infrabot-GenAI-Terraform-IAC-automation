output "migration_job_name" {
  description = "Database migration job name"
  value       = google_database_migration_service_migration_job.main.name
}
