resource "aws_backup_vault" "main" {
  name = "VAULT-AWS-DEV-01"

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "aws_backup_plan" "main" {
  name = "PLAN-AWS-DEV-01"

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
  name         = "SEL-AWS-DEV-01"
  iam_role_arn = var.backup_role_arn
  plan_id      = aws_backup_plan.main.id

  resources = var.backup_resources
}
