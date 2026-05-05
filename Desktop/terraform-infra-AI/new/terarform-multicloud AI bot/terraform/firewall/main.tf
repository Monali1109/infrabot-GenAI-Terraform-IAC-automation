resource "azurerm_network_security_group" "app_nsg" {
  name                = "NSG_AZURE_APP_DEV-01"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH-Admin"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.admin_cidr
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_network_security_group" "db_nsg" {
  name                = "NSG_AZURE_DB_DEV-01"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-PostgreSQL-From-App"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = var.app_subnet_cidr
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
