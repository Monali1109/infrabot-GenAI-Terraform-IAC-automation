resource "aws_backup_vault" "main" {
  name = "VAULT-AWS-TEST-01"

  tags = {
    Environment = "test"
    ManagedBy   = "Terraform"
  }
}

resource "aws_backup_plan" "main" {
  name = "PLAN-AWS-TEST-01"

  rule {
    rule_name         = "daily_backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 2 * * ? *)"

    lifecycle {
      delete_after = 30
    }
  }
}

resource "aws_backup_selection" "main" {
  name         = "SEL-AWS-TEST-01"
  iam_role_arn = var.backup_role_arn
  plan_id      = aws_backup_plan.main.id

  resources = var.backup_resources
}
