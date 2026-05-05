resource "azurerm_user_assigned_identity" "app" {
  name                = "ID-AZURE-APP-DEV-01"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_role_assignment" "app_reader" {
  scope                = var.resource_group_id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}

resource "azurerm_user_assigned_identity" "db" {
  name                = "ID-AZURE-DB-DEV-01"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_role_assignment" "db_contributor" {
  scope                = var.resource_group_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.db.principal_id
}
