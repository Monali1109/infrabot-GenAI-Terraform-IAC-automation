output "app_role_arn" {
  description = "App IAM role ARN"
  value       = aws_iam_role.app_role.arn
}

output "app_instance_profile_name" {
  description = "App instance profile name"
  value       = aws_iam_instance_profile.app.name
}
