variable "availability_zone" {
  type        = string
  default     = "us-east-1a"
  description = "AZ for EBS volumes"
}

variable "kms_key_id" {
  type        = string
  description = "KMS key ID for encryption"
}
