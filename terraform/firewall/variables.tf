variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "admin_cidr" {
  type        = string
  default     = "10.0.0.0/8"
  description = "Admin CIDR for SSH access"
}
