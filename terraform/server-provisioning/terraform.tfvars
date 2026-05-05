region = "us-east-1"

# After running virtual-network, find subnet ID in AWS Console:
#   EC2 -> Subnets -> search Name = "SUBNET_AWS_APP_PROD-01"
subnet_id = "subnet-REPLACE_AFTER_VPC_DEPLOY"

# EC2 -> Key Pairs -> use existing or create one
key_name  = "REPLACE_WITH_YOUR_KEY_PAIR_NAME"
