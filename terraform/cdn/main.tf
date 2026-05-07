# ── Azure CDN: portal-cdn-test (test) ──────────────────────────────
resource "azurerm_cdn_profile" "cdn-1778175750181" {
  name                = "portal-cdn-test"
  location            = "westeurope"
  resource_group_name = "rg-cdn-test"
  sku                 = "Standard_Verizon"

  tags = {
    Environment = "test"
    ManagedBy = "Terraform"
    Project = "ClientPortal"
  }
}

resource "azurerm_cdn_endpoint" "cdn-1778175750181_endpoint" {
  name                = "portal-test-endpoint"
  profile_name        = azurerm_cdn_profile.cdn-1778175750181.name
  location            = azurerm_cdn_profile.cdn-1778175750181.location
  resource_group_name = "rg-cdn-test"
  is_https_allowed    = true
  is_http_allowed     = true

  origin {
    name      = "origin-1"
    host_name = "portalassets.blob.core.windows.net"
  }

  global_delivery_rule {
    cache_expiration_action {
      behavior = "SetIfMissing"
      duration = "40.00:00:00"
    }
  }

  tags = {
    Environment = "test"
    ManagedBy = "Terraform"
    Project = "ClientPortal"
  }
}

output "cdn-1778175750181_cdn_endpoint_url"     { value = "https://portal-test-endpoint.azureedge.net" }
output "cdn-1778175750181_cdn_profile_id"       { value = azurerm_cdn_profile.cdn-1778175750181.id }
output "cdn-1778175750181_origin_hostname"      { value = "portalassets.blob.core.windows.net" }