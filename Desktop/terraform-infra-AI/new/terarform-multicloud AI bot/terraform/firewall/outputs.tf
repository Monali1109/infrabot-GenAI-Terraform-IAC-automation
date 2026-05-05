output "app_nsg_id" {
  description = "App NSG ID"
  value       = azurerm_network_security_group.app_nsg.id
}

output "db_nsg_id" {
  description = "DB NSG ID"
  value       = azurerm_network_security_group.db_nsg.id
}
