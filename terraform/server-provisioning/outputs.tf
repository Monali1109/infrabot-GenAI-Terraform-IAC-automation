output "azapppd01_private_ip" {
  description = "Private IP of AZAPPPD01"
  value       = azurerm_linux_virtual_machine.azapppd01.private_ip_address
}

output "azapppd01_vm_id" {
  description = "VM ID of AZAPPPD01"
  value       = azurerm_linux_virtual_machine.azapppd01.id
}

output "azdbpd01_private_ip" {
  description = "Private IP of AZDBPD01"
  value       = azurerm_linux_virtual_machine.azdbpd01.private_ip_address
}

output "azdbpd01_vm_id" {
  description = "VM ID of AZDBPD01"
  value       = azurerm_linux_virtual_machine.azdbpd01.id
}
