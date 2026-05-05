# IAM -> Roles -> search "AWSBackupDefaultServiceRole" (auto-created by AWS Backup)
backup_role_arn  = "arn:aws:iam::ACCOUNT_ID:role/AWSBackupDefaultServiceRole"

# EC2 instances already defined in server-provisioning:
#   AWSAPPDE01 -> 10.20.1.10
#   AWSDBDE01  -> 10.20.2.11
backup_resources = [
  "arn:aws:ec2:us-east-1:ACCOUNT_ID:instance/REPLACE_APP_INSTANCE_ID",
  "arn:aws:ec2:us-east-1:ACCOUNT_ID:instance/REPLACE_DB_INSTANCE_ID"
]
