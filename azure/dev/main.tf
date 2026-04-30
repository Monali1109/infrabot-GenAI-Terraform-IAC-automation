# ── Compute: gmolq40on (dev) ─────────────────────────────────
variable "gmolq40on_vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_D2s_v3"
}
variable "gmolq40on_count" {
  description = "Number of VMs"
  type        = number
  default     = 1
}
variable "gmolq40on_os_disk_size" {
  description = "OS disk size GB"
  type        = number
  default     = 128
}

data "azurerm_subnet" "gmolq40on_subnet" {
  name                 = "${var.subnet_name}"
  virtual_network_name = "${var.vnet_name}"
  resource_group_name  = var.resource_group_name
}

resource "azurerm_network_interface" "gmolq40on_nic" {
  count               = var.gmolq40on_count
  name                = "gmolq40on-gmolq40on-nic-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.azure_location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.gmolq40on_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "gmolq40on" {
  count               = var.gmolq40on_count
  name                = "gmolq40on-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.azure_location
  size                = var.gmolq40on_vm_size
  admin_username      = "azureadmin"
  network_interface_ids = [azurerm_network_interface.gmolq40on_nic[count.index].id]

  admin_ssh_key {
    username   = "azureadmin"
    public_key = var.ssh_public_key
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.gmolq40on_os_disk_size
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  identity { type = "SystemAssigned" }
  tags = { environment = "dev", generation = "gmolq40on", name = "gmolq40on" }
}

output "gmolq40on_ids"         { value = azurerm_linux_virtual_machine.gmolq40on[*].id }
output "gmolq40on_private_ips" { value = azurerm_network_interface.gmolq40on_nic[*].private_ip_address }