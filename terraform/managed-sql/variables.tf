variable "db_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for RDS"
}

variable "db_security_group_id" {
  type        = string
  description = "Security group for RDS"
}

variable "db_password" {
  type        = string
  description = "Database admin password"
}
