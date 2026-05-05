resource "azurerm_database_migration_service" "main" {
  name                = "DMS-AZURE-DEV-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  sku_name            = "Standard_1vCores"

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_database_migration_project" "main" {
  name                = "DMSPROJ-AZURE-DEV-01"
  service_name        = azurerm_database_migration_service.main.name
  resource_group_name = var.resource_group_name
  location            = var.location
  source_platform     = "PostgreSql"
  target_platform     = "AzureDbForPostgreSql"
}
