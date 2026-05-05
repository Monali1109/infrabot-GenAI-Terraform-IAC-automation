resource "google_sql_database_instance" "main" {
  name             = "sql-gcp-test-01"
  database_version = "POSTGRES_15"
  region           = var.region
  deletion_protection = false

  settings {
    tier = "db-custom-2-7680"

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
    }

    backup_configuration {
      enabled            = true
      start_time         = "02:00"
      binary_log_enabled = false
      backup_retention_settings {
        retained_backups = 7
      }
    }

    availability_type = "ZONAL"
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
