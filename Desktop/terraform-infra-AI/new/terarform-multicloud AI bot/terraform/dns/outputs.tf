output "dns_zone_name" {
  description = "Cloud DNS zone name"
  value       = google_dns_managed_zone.main.name
}
