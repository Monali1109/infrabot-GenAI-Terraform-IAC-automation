output "azapptst01_private_ip" {
  description = "Private IP of AZAPPTST01"
  value       = azurerm_linux_virtual_machine.azapptst01.private_ip_address
}

output "azapptst01_vm_id" {
  description = "VM ID of AZAPPTST01"
  value       = azurerm_linux_virtual_machine.azapptst01.id
}

output "azdbtst01_private_ip" {
  description = "Private IP of AZDBTST01"
  value       = azurerm_linux_virtual_machine.azdbtst01.private_ip_address
}

output "azdbtst01_vm_id" {
  description = "VM ID of AZDBTST01"
  value       = azurerm_linux_virtual_machine.azdbtst01.id
}
