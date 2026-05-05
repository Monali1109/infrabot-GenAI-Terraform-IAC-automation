output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "app_subnet_id" {
  description = "App subnet ID"
  value       = aws_subnet.app.id
}

output "db_subnet_id" {
  description = "DB subnet ID"
  value       = aws_subnet.db.id
}
