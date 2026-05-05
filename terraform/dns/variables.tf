variable "network_url" {
  type        = string
  description = "VPC network URL"
}

variable "app_private_ip" {
  type        = string
  default     = "10.20.1.10"
  description = "App server private IP"
}

variable "db_private_ip" {
  type        = string
  default     = "10.20.2.10"
  description = "DB server private IP"
}
