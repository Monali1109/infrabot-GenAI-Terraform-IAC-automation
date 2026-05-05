output "vnet_id" {
  description = "VNet ID"
  value       = azurerm_virtual_network.main.id
}

output "app_subnet_id" {
  description = "App subnet ID"
  value       = azurerm_subnet.app.id
}

output "db_subnet_id" {
  description = "DB subnet ID"
  value       = azurerm_subnet.db.id
}
