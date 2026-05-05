output "app_identity_id" {
  description = "App managed identity ID"
  value       = azurerm_user_assigned_identity.app.id
}

output "app_identity_principal_id" {
  description = "App managed identity principal ID"
  value       = azurerm_user_assigned_identity.app.principal_id
}
