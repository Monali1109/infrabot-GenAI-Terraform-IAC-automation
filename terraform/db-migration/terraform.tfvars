# EC2 -> Security Groups -> search Name = "SG_AWS_APP_DEV-01"
dms_security_group_id = "sg-REPLACE_AFTER_FIREWALL_DEPLOY"
dms_subnet_group_id   = "REPLACE_WITH_DMS_SUBNET_GROUP"

source_db_host        = "REPLACE_WITH_SOURCE_HOST"
source_db_name        = "REPLACE_WITH_SOURCE_DB"
source_db_user        = "REPLACE_WITH_SOURCE_USER"
source_db_password    = "REPLACE_WITH_SOURCE_PASSWORD"

# Target is the RDS instance: rds-aws-dev-01
target_db_host        = "REPLACE_WITH_RDS_ENDPOINT"
target_db_name        = "appdb"
target_db_user        = "dbadmin"
target_db_password    = "REPLACE_WITH_TARGET_PASSWORD"
