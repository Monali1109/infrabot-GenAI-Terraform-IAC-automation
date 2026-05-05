output "app_volume_id" {
  description = "App EBS volume ID"
  value       = aws_ebs_volume.app_data.id
}

output "db_volume_id" {
  description = "DB EBS volume ID"
  value       = aws_ebs_volume.db_data.id
}
