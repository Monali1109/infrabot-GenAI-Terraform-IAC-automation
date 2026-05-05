resource "azurerm_network_interface" "azapptst01_nic" {
  name                = "AZAPPTST01-NIC"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.30.1.10"
  }
}

resource "azurerm_linux_virtual_machine" "azapptst01" {
  name                = "AZAPPTST01"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_F4s_v2"
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.azapptst01_nic.id]

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
    Name        = "AZAPPTST01"
    Environment = "test"
    Role        = "app"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_network_interface" "azdbtst01_nic" {
  name                = "AZDBTST01-NIC"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.30.2.11"
  }
}

resource "azurerm_linux_virtual_machine" "azdbtst01" {
  name                = "AZDBTST01"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_D8s_v3"
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.azdbtst01_nic.id]

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
    Name        = "AZDBTST01"
    Environment = "test"
    Role        = "db"
    ManagedBy   = "Terraform"
  }
}
