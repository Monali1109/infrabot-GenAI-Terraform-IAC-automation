output "secret_id" {
  description = "Secret Manager secret ID"
  value       = google_secret_manager_secret.db_password.id
}

output "kms_key_id" {
  description = "KMS crypto key ID"
  value       = google_kms_crypto_key.secrets.id
}
