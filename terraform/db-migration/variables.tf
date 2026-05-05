variable "dms_security_group_id" {
  type        = string
  description = "Security group for DMS"
}

variable "dms_subnet_group_id" {
  type        = string
  description = "Subnet group for DMS"
}

variable "source_db_host" {
  type        = string
  description = "Source database hostname"
}

variable "source_db_name" {
  type        = string
  description = "Source database name"
}

variable "source_db_user" {
  type        = string
  description = "Source database username"
}

variable "source_db_password" {
  type        = string
  description = "Source database password"
}

variable "target_db_host" {
  type        = string
  description = "Target database hostname"
}

variable "target_db_name" {
  type        = string
  description = "Target database name"
}

variable "target_db_user" {
  type        = string
  description = "Target database username"
}

variable "target_db_password" {
  type        = string
  description = "Target database password"
}
