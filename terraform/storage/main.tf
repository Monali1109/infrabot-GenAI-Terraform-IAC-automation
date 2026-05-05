resource "aws_ebs_volume" "app_data" {
  availability_zone = var.availability_zone
  size              = 100
  type              = "gp3"
  iops              = 3000
  throughput        = 125
  encrypted         = true
  kms_key_id        = var.kms_key_id

  tags = {
    Name        = "EBS-AWS-APP-TEST-01"
    Environment = "test"
    ManagedBy   = "Terraform"
  }
}

resource "aws_ebs_volume" "db_data" {
  availability_zone = var.availability_zone
  size              = 500
  type              = "gp3"
  iops              = 6000
  throughput        = 250
  encrypted         = true
  kms_key_id        = var.kms_key_id

  tags = {
    Name        = "EBS-AWS-DB-TEST-01"
    Environment = "test"
    ManagedBy   = "Terraform"
  }
}
