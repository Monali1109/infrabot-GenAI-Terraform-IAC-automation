location            = "East US"
resource_group_name = "RG-AZURE-PROD-01"

# Azure Portal -> Public IP Addresses -> create PIP-AZURE-PROD-01 first
# Then paste its resource ID (replace SUBSCRIPTION_ID):
public_ip_id        = "/subscriptions/REPLACE_WITH_AZURE_SUBSCRIPTION_ID/resourceGroups/RG-AZURE-PROD-01/providers/Microsoft.Network/publicIPAddresses/PIP-AZURE-PROD-01"
