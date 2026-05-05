variable "availability_zone" {
  type        = string
  default     = "us-east-1a"
  description = "AZ for subnets"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}
