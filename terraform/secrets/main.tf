resource "aws_secretsmanager_secret" "db_password" {
  name                    = "/prod/database/password"
  recovery_window_in_days = 30

  tags = {
    Name        = "SECRET-AWS-DB-PWD-PROD-01"
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = "dbadmin"
    password = var.db_password
  })
}

resource "aws_kms_key" "secrets" {
  description             = "KMS key for prod secrets encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name        = "KMS-AWS-SECRETS-PROD-01"
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/prod/secrets"
  target_key_id = aws_kms_key.secrets.key_id
}
