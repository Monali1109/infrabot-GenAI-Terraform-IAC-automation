variable "location" {
  type        = string
  default     = "East US"
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "public_ip_id" {
  type        = string
  description = "Public IP resource ID"
}
