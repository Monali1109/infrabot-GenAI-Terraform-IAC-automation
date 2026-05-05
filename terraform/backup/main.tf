resource "google_compute_resource_policy" "daily_snapshot" {
  name   = "policy-gcp-prod-daily-snap"
  region = var.region

  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "02:00"
      }
    }

    retention_policy {
      max_retention_days    = 90
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }

    snapshot_properties {
      labels = {
        environment = "prod"
        managed_by  = "terraform"
      }
    }
  }
}

resource "google_compute_disk_resource_policy_attachment" "app" {
  name    = google_compute_resource_policy.daily_snapshot.name
  disk    = var.app_disk_name
  zone    = var.zone
}
