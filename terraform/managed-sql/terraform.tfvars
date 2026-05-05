# EC2 -> Subnets -> Names: "SUBNET_AWS_DB_PROD-01"
db_subnet_ids        = ["subnet-REPLACE_DB_SUBNET_1", "subnet-REPLACE_DB_SUBNET_2"]

# EC2 -> Security Groups -> search Name = "SG_AWS_DB_PROD-01"
db_security_group_id = "sg-REPLACE_AFTER_FIREWALL_DEPLOY"

# IMPORTANT: Do not commit real passwords — use AWS Secrets Manager in production
db_password          = "REPLACE_WITH_SECURE_PASSWORD"
