variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region"
}

variable "db_password" {
  type        = string
  description = "Database password"
}

variable "app_service_account" {
  type        = string
  description = "App service account email"
}
