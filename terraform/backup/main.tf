resource "azurerm_recovery_services_vault" "main" {
  name                = "RSV-AZURE-PROD-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  tags = {
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_backup_policy_vm" "daily" {
  name                = "POLICY-AZURE-VM-PROD-01"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.main.name

  backup {
    frequency = "Daily"
    time      = "02:00"
  }

  retention_daily {
    count = 90
  }
}

resource "azurerm_backup_protected_vm" "app" {
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.main.name
  source_vm_id        = var.app_vm_id
  backup_policy_id    = azurerm_backup_policy_vm.daily.id
}
