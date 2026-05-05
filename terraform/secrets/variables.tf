variable "location" {
  type        = string
  default     = "East US"
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID"
}

variable "db_password" {
  type        = string
  description = "Database password to store"
}
