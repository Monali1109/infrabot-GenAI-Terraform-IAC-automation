output "azappdv01_private_ip" {
  description = "Private IP of AZAPPDV01"
  value       = azurerm_linux_virtual_machine.azappdv01.private_ip_address
}

output "azappdv01_vm_id" {
  description = "VM ID of AZAPPDV01"
  value       = azurerm_linux_virtual_machine.azappdv01.id
}

output "azdbdv01_private_ip" {
  description = "Private IP of AZDBDV01"
  value       = azurerm_linux_virtual_machine.azdbdv01.private_ip_address
}

output "azdbdv01_vm_id" {
  description = "VM ID of AZDBDV01"
  value       = azurerm_linux_virtual_machine.azdbdv01.id
}
