resource "azurerm_private_dns_zone" "main" {
  name                = "prod.example.internal"
  resource_group_name = var.resource_group_name

  tags = {
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  name                  = "dns-vnet-link-prod"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.main.name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = true
}

resource "azurerm_private_dns_a_record" "app" {
  name                = "app"
  zone_name           = azurerm_private_dns_zone.main.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [var.app_private_ip]
}

resource "azurerm_private_dns_a_record" "db" {
  name                = "db"
  zone_name           = azurerm_private_dns_zone.main.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [var.db_private_ip]
}
