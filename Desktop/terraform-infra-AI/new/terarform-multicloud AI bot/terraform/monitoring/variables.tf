variable "sns_topic_arn" {
  type        = string
  description = "SNS topic for alerts"
}

variable "asg_name" {
  type        = string
  description = "Auto Scaling Group name"
}
