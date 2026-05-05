resource "google_sql_database_instance" "main" {
  name             = "sql-gcp-prod-01"
  database_version = "POSTGRES_15"
  region           = var.region
  deletion_protection = true

  settings {
    tier = "db-custom-4-15360"

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
    }

    backup_configuration {
      enabled            = true
      start_time         = "02:00"
      binary_log_enabled = false
      backup_retention_settings {
        retained_backups = 30
      }
    }

    availability_type = "REGIONAL"
  }
}

resource "google_sql_database" "app" {
  name     = "appdb"
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "app" {
  name     = "appuser"
  instance = google_sql_database_instance.main.name
  password = var.db_password
}
