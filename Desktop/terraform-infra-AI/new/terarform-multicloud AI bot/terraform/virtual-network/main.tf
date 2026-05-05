resource "azurerm_virtual_network" "main" {
  name                = "VPC_AZURE_TEST-01"
  address_space       = ["10.30.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    Environment = "test"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_subnet" "app" {
  name                 = "SUBNET_AZURE_APP_TEST-01"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.30.1.0/24"]
}

resource "azurerm_subnet" "db" {
  name                 = "SUBNET_AZURE_DB_TEST-01"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.30.2.0/24"]
}
