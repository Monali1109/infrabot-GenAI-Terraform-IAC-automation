resource "azurerm_lb" "main" {
  name                = "LB-AZURE-DEV-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = var.public_ip_id
  }

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_lb_backend_address_pool" "app" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "BackendPool-App"
}

resource "azurerm_lb_probe" "https" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "https-probe"
  port            = 443
  protocol        = "Https"
  request_path    = "/health"
}

resource "azurerm_lb_rule" "https" {
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "HTTPS"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app.id]
  probe_id                       = azurerm_lb_probe.https.id
}
