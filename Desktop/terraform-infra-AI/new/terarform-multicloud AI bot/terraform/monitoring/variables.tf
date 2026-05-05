variable "location" {
  type        = string
  default     = "East US"
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "vm_id" {
  type        = string
  description = "VM resource ID for alerts"
}

variable "action_group_id" {
  type        = string
  description = "Action group ID for alerts"
}
