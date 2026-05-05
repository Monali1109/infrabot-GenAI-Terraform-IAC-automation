resource "azurerm_key_vault" "main" {
  name                        = "KV-AZURE-PROD-01"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 30
  purge_protection_enabled    = true

  tags = {
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "prod-db-password"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.main.id

  tags = {
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_key_vault_key" "encryption" {
  name         = "prod-encryption-key"
  key_vault_id = azurerm_key_vault.main.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
}
