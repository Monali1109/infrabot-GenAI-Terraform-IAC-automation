variable "location" {
  type        = string
  default     = "East US"
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "subnet_id" {
  type        = string
  description = "Subnet resource ID"
}

variable "admin_username" {
  type        = string
  default     = "azureuser"
  description = "VM admin username"
}
