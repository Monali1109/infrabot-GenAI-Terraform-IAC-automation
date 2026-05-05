resource "azurerm_network_security_group" "app_nsg" {
  name                = "NSG_AZURE_APP_TEST-01"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH-Admin"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.admin_cidr
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "test"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_network_security_group" "db_nsg" {
  name                = "NSG_AZURE_DB_TEST-01"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-PostgreSQL-From-App"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = var.app_subnet_cidr
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "test"
    ManagedBy   = "Terraform"
  }
}


# ── Firewall: gmosw2om5 (test) ──────────────────────────────────
variable "gmosw2om5_nsg_priority" {
  description = "NSG rule priority (lower = higher precedence)"
  type        = number
  default     = 200
}

resource "azurerm_network_security_group" "gmosw2om5_nsg" {
  name                = "${var.project_name}-gmosw2om5-nsg"
  resource_group_name = var.resource_group_name
  location            = var.azure_location

  security_rule {
    name                       = "gmosw2om5-allow"
    priority                   = var.gmosw2om5_nsg_priority
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "43"
    source_address_prefix      = "10.20.0.23/32"
    destination_address_prefix = "198.168.20.7/32"
    description                = "gmosw2om5 allow rule in test"
  }

  security_rule {
    name                       = "gmosw2om5-deny-all"
    priority                   = 4096
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Default deny all — must be last rule"
  }

  tags = { environment = "test", generation = "gmosw2om5" }
}

output "gmosw2om5_nsg_id" { value = azurerm_network_security_group.gmosw2om5_nsg.id }