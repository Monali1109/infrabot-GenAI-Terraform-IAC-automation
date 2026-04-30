# ── Compute: gmol9gebu (prod) ─────────────────────────────────
variable "gmol9gebu_vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_D2s_v3"
}
variable "gmol9gebu_count" {
  description = "Number of VMs"
  type        = number
  default     = 1
}
variable "gmol9gebu_os_disk_size" {
  description = "OS disk size GB"
  type        = number
  default     = 128
}

data "azurerm_subnet" "gmol9gebu_subnet" {
  name                 = "${var.subnet_name}"
  virtual_network_name = "${var.vnet_name}"
  resource_group_name  = var.resource_group_name
}

resource "azurerm_network_interface" "gmol9gebu_nic" {
  count               = var.gmol9gebu_count
  name                = "gmol9gebu-gmol9gebu-nic-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.azure_location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.gmol9gebu_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "gmol9gebu" {
  count               = var.gmol9gebu_count
  name                = "gmol9gebu-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.azure_location
  size                = var.gmol9gebu_vm_size
  admin_username      = "azureadmin"
  network_interface_ids = [azurerm_network_interface.gmol9gebu_nic[count.index].id]

  admin_ssh_key {
    username   = "azureadmin"
    public_key = var.ssh_public_key
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.gmol9gebu_os_disk_size
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  identity { type = "SystemAssigned" }
  tags = { environment = "prod", generation = "gmol9gebu", name = "gmol9gebu" }
}

output "gmol9gebu_ids"         { value = azurerm_linux_virtual_machine.gmol9gebu[*].id }
output "gmol9gebu_private_ips" { value = azurerm_network_interface.gmol9gebu_nic[*].private_ip_address }