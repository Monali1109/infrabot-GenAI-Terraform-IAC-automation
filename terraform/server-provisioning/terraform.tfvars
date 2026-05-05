location            = "East US"
resource_group_name = "RG-AZURE-TEST-01"
admin_username      = "azureuser"

# Get subnet_id from virtual-network module output (full resource ID)
subnet_id           = "/subscriptions/SUBSCRIPTION_ID/resourceGroups/RG-AZURE-TEST-01/providers/Microsoft.Network/virtualNetworks/VPC_AZURE_TEST-01/subnets/SUBNET_AZURE_APP_TEST-01"
