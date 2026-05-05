output "recovery_vault_id" {
  description = "Recovery Services Vault ID"
  value       = azurerm_recovery_services_vault.main.id
}

output "backup_policy_id" {
  description = "VM backup policy ID"
  value       = azurerm_backup_policy_vm.daily.id
}
