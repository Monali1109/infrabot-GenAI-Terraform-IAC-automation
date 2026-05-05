output "alert_policy_name" {
  description = "Alert policy name"
  value       = google_monitoring_alert_policy.cpu_high.name
}
