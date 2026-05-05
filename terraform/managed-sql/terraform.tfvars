region     = "us-central1"

# Get network_id from virtual-network module output
network_id = "REPLACE_WITH_VPC_NETWORK_SELF_LINK"

# Use a secrets manager in production — do NOT commit real passwords
db_password = "REPLACE_WITH_SECURE_PASSWORD"
