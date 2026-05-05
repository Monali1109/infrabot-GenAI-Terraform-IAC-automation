resource "azurerm_network_interface" "azapppd01_nic" {
  name                = "AZAPPPD01-NIC"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.10.1.10"
  }
}

resource "azurerm_linux_virtual_machine" "azapppd01" {
  name                = "AZAPPPD01"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_F4s_v2"
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.azapppd01_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    Name        = "AZAPPPD01"
    Environment = "prod"
    Role        = "app"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_network_interface" "azdbpd01_nic" {
  name                = "AZDBPD01-NIC"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.10.2.11"
  }
}

resource "azurerm_linux_virtual_machine" "azdbpd01" {
  name                = "AZDBPD01"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_D8s_v3"
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.azdbpd01_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    Name        = "AZDBPD01"
    Environment = "prod"
    Role        = "db"
    ManagedBy   = "Terraform"
  }
}
