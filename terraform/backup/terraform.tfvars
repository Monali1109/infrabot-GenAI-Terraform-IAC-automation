# IAM -> Roles -> search "AWSBackupDefaultServiceRole" (auto-created by AWS Backup)
backup_role_arn  = "arn:aws:iam::ACCOUNT_ID:role/AWSBackupDefaultServiceRole"

# EC2 instances already defined in server-provisioning:
#   AWSAPPTE01 -> 10.30.1.10
#   AWSDBTE01  -> 10.30.2.11
backup_resources = [
  "arn:aws:ec2:us-east-1:ACCOUNT_ID:instance/REPLACE_APP_INSTANCE_ID",
  "arn:aws:ec2:us-east-1:ACCOUNT_ID:instance/REPLACE_DB_INSTANCE_ID"
]
