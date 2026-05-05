resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/test/app"
  retention_in_days = 30

  tags = {
    Environment = "test"
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "CWA-AWS-CPU-HIGH-TEST-01"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "CPU utilization exceeds 80% in test"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "DASH-AWS-TEST-01"
  dashboard_body = jsonencode({
    widgets = [{
      type = "metric"
      properties = {
        title  = "TEST CPU Utilization"
        period = 300
        stat   = "Average"
        metrics = [["AWS/EC2", "CPUUtilization"]]
      }
    }]
  })
}
