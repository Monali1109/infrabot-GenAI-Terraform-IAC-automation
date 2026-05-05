resource "google_database_migration_service_migration_job" "main" {
  location         = var.region
  migration_job_id = "dms-gcp-test-01"
  type             = "CONTINUOUS"
  source           = google_database_migration_service_connection_profile.source.name
  destination      = google_database_migration_service_connection_profile.dest.name
}

resource "google_database_migration_service_connection_profile" "source" {
  location              = var.region
  connection_profile_id = "src-gcp-test-01"

  postgresql {
    host     = var.source_db_host
    port     = 5432
    username = var.source_db_user
    password = var.source_db_password
    database = var.source_db_name
  }
}

resource "google_database_migration_service_connection_profile" "dest" {
  location              = var.region
  connection_profile_id = "dst-gcp-test-01"

  postgresql {
    host     = var.target_db_host
    port     = 5432
    username = var.target_db_user
    password = var.target_db_password
    database = var.target_db_name
  }
}
