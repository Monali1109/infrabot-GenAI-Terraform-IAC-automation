location            = "East US"
resource_group_name = "RG-AZURE-PROD-01"
admin_username      = "azureuser"

# Azure Portal -> Virtual Networks -> VPC_AZURE_PROD-01 -> Subnets -> SUBNET_AZURE_APP_PROD-01
# Copy the subnet resource ID and replace SUBSCRIPTION_ID below:
subnet_id           = "/subscriptions/REPLACE_WITH_AZURE_SUBSCRIPTION_ID/resourceGroups/RG-AZURE-PROD-01/providers/Microsoft.Network/virtualNetworks/VPC_AZURE_PROD-01/subnets/SUBNET_AZURE_APP_PROD-01"
