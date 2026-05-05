# VPC -> Your VPCs -> search Name = "VPC_AWS_PROD-01"
vpc_id            = "vpc-REPLACE_AFTER_VPC_DEPLOY"

# EC2 -> Security Groups -> search Name = "SG_AWS_APP_PROD-01"
security_group_id = "sg-REPLACE_AFTER_FIREWALL_DEPLOY"

# EC2 -> Subnets -> Names: "SUBNET_AWS_APP_PROD-01" and "SUBNET_AWS_DB_PROD-01"
subnet_ids        = ["subnet-REPLACE_SUBNET_1", "subnet-REPLACE_SUBNET_2"]

# AWS Certificate Manager -> Certificates
certificate_arn   = "arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/REPLACE"
