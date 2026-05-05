backup_role_arn  = "arn:aws:iam::ACCOUNT_ID:role/AWSBackupDefaultServiceRole"

# Add ARNs of resources to back up (EC2, RDS, etc.)
backup_resources = [
  "arn:aws:ec2:us-east-1:ACCOUNT_ID:instance/REPLACE_WITH_INSTANCE_ID"
]
