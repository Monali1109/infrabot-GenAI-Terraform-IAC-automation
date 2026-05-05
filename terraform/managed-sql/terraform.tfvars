db_subnet_ids        = ["subnet-REPLACE_WITH_DB_SUBNET_1", "subnet-REPLACE_WITH_DB_SUBNET_2"]
db_security_group_id = "sg-REPLACE_WITH_DB_SG_ID"

# Use a secrets manager in production — do NOT commit real passwords
db_password          = "REPLACE_WITH_SECURE_PASSWORD"
