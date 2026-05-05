resource "azurerm_virtual_network" "main" {
  name                = "VPC_AZURE_DEV-01"
  address_space       = ["10.20.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_subnet" "app" {
  name                 = "SUBNET_AZURE_APP_DEV-01"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.20.1.0/24"]
}

resource "azurerm_subnet" "db" {
  name                 = "SUBNET_AZURE_DB_DEV-01"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.20.2.0/24"]
}
