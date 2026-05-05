resource "azurerm_postgresql_flexible_server" "main" {
  name                   = "psql-azure-prod-01"
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = "15"
  administrator_login    = "dbadmin"
  administrator_password = var.db_password
  zone                   = "1"

  sku_name   = "GP_Standard_D4s_v3"
  storage_mb = 131072

  backup_retention_days        = 30
  geo_redundant_backup_enabled = true

  tags = {
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_postgresql_flexible_server_database" "app" {
  name      = "appdb"
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}
