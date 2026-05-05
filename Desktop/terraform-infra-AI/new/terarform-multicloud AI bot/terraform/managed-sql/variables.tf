variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region"
}

variable "network_id" {
  type        = string
  description = "VPC network ID"
}

variable "db_password" {
  type        = string
  description = "Database admin password"
}
