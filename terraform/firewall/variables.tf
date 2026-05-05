variable "network" {
  type        = string
  description = "VPC network name"
}

variable "admin_cidr" {
  type        = string
  default     = "10.0.0.0/8"
  description = "Admin CIDR for SSH"
}
