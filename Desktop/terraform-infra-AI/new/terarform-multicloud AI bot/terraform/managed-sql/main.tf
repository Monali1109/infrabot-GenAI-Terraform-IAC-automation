resource "azurerm_postgresql_flexible_server" "main" {
  name                   = "psql-azure-dev-01"
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = "15"
  administrator_login    = "dbadmin"
  administrator_password = var.db_password
  zone                   = "1"

  sku_name   = "B_Standard_B2s"
  storage_mb = 32768

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_postgresql_flexible_server_database" "app" {
  name      = "appdb"
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}
