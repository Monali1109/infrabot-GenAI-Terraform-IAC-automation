output "app_sg_id" {
  description = "App security group ID"
  value       = aws_security_group.app_sg.id
}

output "db_sg_id" {
  description = "DB security group ID"
  value       = aws_security_group.db_sg.id
}
