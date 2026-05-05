output "app_disk_id" {
  description = "App managed disk ID"
  value       = azurerm_managed_disk.app_data.id
}

output "db_disk_id" {
  description = "DB managed disk ID"
  value       = azurerm_managed_disk.db_data.id
}
