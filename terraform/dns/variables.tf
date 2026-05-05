variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "virtual_network_id" {
  type        = string
  description = "VNet resource ID"
}

variable "app_private_ip" {
  type        = string
  default     = "10.10.1.10"
  description = "App server private IP"
}

variable "db_private_ip" {
  type        = string
  default     = "10.10.2.10"
  description = "DB server private IP"
}
