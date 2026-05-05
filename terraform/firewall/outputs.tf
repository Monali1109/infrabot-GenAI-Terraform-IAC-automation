output "https_firewall_name" {
  description = "HTTPS firewall rule name"
  value       = google_compute_firewall.allow_https.name
}

output "db_firewall_name" {
  description = "DB firewall rule name"
  value       = google_compute_firewall.allow_db_internal.name
}
