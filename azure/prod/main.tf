# Ã¢ÂÂÃ¢ÂÂ Compute: gmol9ls0a (prod) Ã¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂÃ¢ÂÂ
variable "gmol9ls0a_vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_D2s_v3"
}
variable "gmol9ls0a_count" {
  description = "Number of VMs"
  type        = number
  default     = 1
}
variable "gmol9ls0a_os_disk_size" {
  description = "OS disk size GB"
  type        = number
  default     = 64
}

data "azurerm_subnet" "gmol9ls0a_subnet" {
  name                 = "${var.subnet_name}"
  virtual_network_name = "${var.vnet_name}"
  resource_group_name  = var.resource_group_name
}

resource "azurerm_network_interface" "gmol9ls0a_nic" {
  count               = var.gmol9ls0a_count
  name                = "myserverL2-gmol9ls0a-nic-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.azure_location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.gmol9ls0a_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "gmol9ls0a" {
  count               = var.gmol9ls0a_count
  name                = "myserverL2-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.azure_location
  size                = var.gmol9ls0a_vm_size
  admin_username      = "azureadmin"
  network_interface_ids = [azurerm_network_interface.gmol9ls0a_nic[count.index].id]

  admin_ssh_key {
    username   = "azureadmin"
    public_key = var.ssh_public_key
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.gmol9ls0a_os_disk_size
  }
  source_image_reference {
    publisher = "RedHat"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  identity { type = "SystemAssigned" }
  tags = { environment = "prod", generation = "gmol9ls0a", name = "myserverL2" }
}

output "gmol9ls0a_ids"         { value = azurerm_linux_virtual_machine.gmol9ls0a[*].id }
output "gmol9ls0a_private_ips" { value = azurerm_network_interface.gmol9ls0a_nic[*].private_ip_address }