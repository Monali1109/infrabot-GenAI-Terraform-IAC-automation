resource "azurerm_network_interface" "azappdv01_nic" {
  name                = "AZAPPDV01-NIC"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.20.1.10"
  }
}

resource "azurerm_linux_virtual_machine" "azappdv01" {
  name                = "AZAPPDV01"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_F4s_v2"
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.azappdv01_nic.id]

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
    Name        = "AZAPPDV01"
    Environment = "dev"
    Role        = "app"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_network_interface" "azdbdv01_nic" {
  name                = "AZDBDV01-NIC"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.20.2.11"
  }
}

resource "azurerm_linux_virtual_machine" "azdbdv01" {
  name                = "AZDBDV01"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_D8s_v3"
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.azdbdv01_nic.id]

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
    Name        = "AZDBDV01"
    Environment = "dev"
    Role        = "db"
    ManagedBy   = "Terraform"
  }
}
