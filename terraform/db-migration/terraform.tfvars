location            = "East US"
resource_group_name = "RG-AZURE-PROD-01"

source_db_host      = "REPLACE_WITH_SOURCE_HOST"
source_db_name      = "REPLACE_WITH_SOURCE_DB"
source_db_user      = "REPLACE_WITH_SOURCE_USER"
source_db_password  = "REPLACE_WITH_SOURCE_PASSWORD"

# Target is PostgreSQL server: psql-azure-prod-01
target_db_host      = "REPLACE_WITH_PSQL_FQDN.postgres.database.azure.com"
target_db_name      = "appdb"
target_db_user      = "dbadmin"
target_db_password  = "REPLACE_WITH_TARGET_PASSWORD"
