resource "aws_secretsmanager_secret" "db_password" {
  name                    = "/test/database/password"
  recovery_window_in_days = 7

  tags = {
    Name        = "SECRET-AWS-DB-PWD-TEST-01"
    Environment = "test"
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
  description             = "KMS key for test secrets encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name        = "KMS-AWS-SECRETS-TEST-01"
    Environment = "test"
    ManagedBy   = "Terraform"
  }
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/test/secrets"
  target_key_id = aws_kms_key.secrets.key_id
}
