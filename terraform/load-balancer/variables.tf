variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "security_group_id" {
  type        = string
  description = "Security group for ALB"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs"
}

variable "certificate_arn" {
  type        = string
  description = "ACM certificate ARN"
}
