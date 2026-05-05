output "secret_arn" {
  description = "Secrets Manager secret ARN"
  value       = aws_secretsmanager_secret.db_password.arn
}

output "kms_key_id" {
  description = "KMS key ID"
  value       = aws_kms_key.secrets.key_id
}
