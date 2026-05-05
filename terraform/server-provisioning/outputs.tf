output "awsapppd01_private_ip" {
  description = "Private IP of AWSAPPPD01"
  value       = aws_instance.awsapppd01.private_ip
}

output "awsapppd01_instance_id" {
  description = "Instance ID of AWSAPPPD01"
  value       = aws_instance.awsapppd01.id
}

output "awsdbpd01_private_ip" {
  description = "Private IP of AWSDBPD01"
  value       = aws_instance.awsdbpd01.private_ip
}

output "awsdbpd01_instance_id" {
  description = "Instance ID of AWSDBPD01"
  value       = aws_instance.awsdbpd01.id
}
