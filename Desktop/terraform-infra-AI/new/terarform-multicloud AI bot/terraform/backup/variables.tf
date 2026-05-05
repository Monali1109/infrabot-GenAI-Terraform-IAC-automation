variable "backup_role_arn" {
  type        = string
  description = "IAM role ARN for AWS Backup"
}

variable "backup_resources" {
  type        = list(string)
  default     = []
  description = "Resource ARNs to backup"
}
