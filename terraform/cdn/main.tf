# ── Azure CDN: my-app-cdn (dev) ──────────────────────────────
resource "azurerm_cdn_profile" "cdn-1778083744183" {
  name                = "my-app-cdn"
  location            = "eastus"
  resource_group_name = "rg-cdn-dev"
  sku                 = "Standard_Microsoft"

  tags = { Project = "MyWebsite", Environment = "dev", ManagedBy = "TerraformGenerate" }
}

resource "azurerm_cdn_endpoint" "cdn-1778083744183_endpoint" {
  name                = "my-app-endpoint"
  profile_name        = azurerm_cdn_profile.cdn-1778083744183.name
  location            = azurerm_cdn_profile.cdn-1778083744183.location
  resource_group_name = "rg-cdn-dev"
  is_https_allowed    = false
  is_http_allowed     = true

  origin {
    name      = "origin-1"
    host_name = "mappassets.blob.core.windows.net"
  }

  global_delivery_rule {
    cache_expiration_action {
      behavior = "SetIfMissing"
      duration = "2.00:00:00"
    }
  }

  tags = { Project = "MyWebsite", Environment = "dev", ManagedBy = "TerraformGenerate" }
}

output "cdn-1778083744183_cdn_endpoint_url"   { value = "https://my-app-endpoint.azureedge.net" }
output "cdn-1778083744183_cdn_profile_id"     { value = azurerm_cdn_profile.cdn-1778083744183.id }
output "cdn-1778083744183_origin_hostname"    { value = "mappassets.blob.core.windows.net" }