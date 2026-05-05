variable "location" {
  type        = string
  default     = "East US"
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "admin_cidr" {
  type        = string
  default     = "10.0.0.0/8"
  description = "Admin CIDR for SSH"
}

variable "app_subnet_cidr" {
  type        = string
  description = "App subnet CIDR for DB rules"
}
