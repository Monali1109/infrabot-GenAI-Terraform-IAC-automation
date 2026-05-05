resource "google_logging_log_sink" "app" {
  name        = "sink-gcp-dev-app"
  destination = "storage.googleapis.com/${var.log_bucket}"
  filter      = "resource.type=gce_instance severity>=WARNING"
}

resource "google_monitoring_alert_policy" "cpu_high" {
  display_name = "ALERT-GCP-CPU-HIGH-DEV-01"
  combiner     = "OR"

  conditions {
    display_name = "High CPU"
    condition_threshold {
      filter          = "resource.type=gce_instance"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8
      duration        = "300s"

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = [var.notification_channel]
}

resource "google_monitoring_dashboard" "main" {
  dashboard_json = jsonencode({
    displayName = "DASH-GCP-DEV-01"
    gridLayout  = {
      columns = 2
      widgets = []
    }
  })
}
