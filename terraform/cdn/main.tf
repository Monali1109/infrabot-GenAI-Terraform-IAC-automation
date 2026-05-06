# ── Azure CDN: my-website-cdn (prod) ──────────────────────────────
resource "azurerm_cdn_profile" "cdn-1778049558201" {
  name                = "my-website-cdn"
  location            = "eastus"
  resource_group_name = "rg-cdn-prod"
  sku                 = "Standard_Microsoft"

  tags = { Project = "MyWebsite", Environment = "prod", ManagedBy = "Terraform" }
}

resource "azurerm_cdn_endpoint" "cdn-1778049558201_endpoint" {
  name                = "my-website-endpoint"
  profile_name        = azurerm_cdn_profile.cdn-1778049558201.name
  location            = azurerm_cdn_profile.cdn-1778049558201.location
  resource_group_name = "rg-cdn-prod"
  is_https_allowed    = true
  is_http_allowed     = false

  origin {
    name      = "origin-1"
    host_name = "mywebsiteassets.blob.core.windows.net"
  }

  global_delivery_rule {
    cache_expiration_action {
      behavior = "SetIfMissing"
      duration = "24.00:00:00"
    }
  }

  tags = { Project = "MyWebsite", Environment = "prod", ManagedBy = "Terraform" }
}

output "cdn-1778049558201_cdn_endpoint_url"   { value = "https://my-website-endpoint.azureedge.net" }
output "cdn-1778049558201_cdn_profile_id"     { value = azurerm_cdn_profile.cdn-1778049558201.id }
output "cdn-1778049558201_origin_hostname"    { value = "mywebsiteassets.blob.core.windows.net" }