resource "azurerm_managed_disk" "app_data" {
  name                 = "DISK-AZURE-APP-TEST-01"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 100

  tags = {
    Environment = "test"
    Role        = "app"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_managed_disk" "db_data" {
  name                 = "DISK-AZURE-DB-TEST-01"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 500

  tags = {
    Environment = "test"
    Role        = "db"
    ManagedBy   = "Terraform"
  }
}
