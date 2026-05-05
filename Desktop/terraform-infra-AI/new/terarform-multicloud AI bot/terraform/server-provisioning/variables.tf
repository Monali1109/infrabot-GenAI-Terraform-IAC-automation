variable "subnet_id" {
  type        = string
  description = "Subnet ID for EC2 instances"
}

variable "key_name" {
  type        = string
  description = "EC2 Key Pair name"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}
