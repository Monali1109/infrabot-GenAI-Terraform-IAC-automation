output "snapshot_policy_id" {
  description = "Snapshot resource policy ID"
  value       = google_compute_resource_policy.daily_snapshot.id
}
