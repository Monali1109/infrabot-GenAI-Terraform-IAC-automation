output "dns_zone_id" {
  description = "Private DNS zone ID"
  value       = azurerm_private_dns_zone.main.id
}
