output "awsappdv01_private_ip" {
  description = "Private IP of AWSAPPDV01"
  value       = aws_instance.awsappdv01.private_ip
}

output "awsappdv01_instance_id" {
  description = "Instance ID of AWSAPPDV01"
  value       = aws_instance.awsappdv01.id
}

output "awsdbdv01_private_ip" {
  description = "Private IP of AWSDBDV01"
  value       = aws_instance.awsdbdv01.private_ip
}

output "awsdbdv01_instance_id" {
  description = "Instance ID of AWSDBDV01"
  value       = aws_instance.awsdbdv01.id
}
