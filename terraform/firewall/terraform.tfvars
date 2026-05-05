location            = "East US"
resource_group_name = "RG-AZURE-TEST-01"
admin_cidr          = "10.0.0.0/8"
app_subnet_cidr     = "10.30.1.0/24"


# ── test environment ─────────────────────────────────────────
azure_subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
azure_location        = "eastus"
tf_state_rg           = "tfstate-rg"
tf_state_sa           = "tfstateaccounttest"
resource_group_name   = "myproject-test-rg"
project_name          = "myproject"
ssh_public_key        = "ssh-rsa AAAA..."

# ── Generation gmosw2om5 ──
gmosw2om5_direction = "Outbound"
gmosw2om5_protocol = "Tcp"
gmosw2om5_priority = "200"
gmosw2om5_access = "Allow"
gmosw2om5_source_ip = "10.20.0.23"
gmosw2om5_dest_ip = "198.168.20.7"