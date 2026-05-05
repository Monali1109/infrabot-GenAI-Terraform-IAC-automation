output "awsapptst01_private_ip" {
  description = "Private IP of AWSAPPTST01"
  value       = aws_instance.awsapptst01.private_ip
}

output "awsapptst01_instance_id" {
  description = "Instance ID of AWSAPPTST01"
  value       = aws_instance.awsapptst01.id
}

output "awsdbtst01_private_ip" {
  description = "Private IP of AWSDBTST01"
  value       = aws_instance.awsdbtst01.private_ip
}

output "awsdbtst01_instance_id" {
  description = "Instance ID of AWSDBTST01"
  value       = aws_instance.awsdbtst01.id
}
