resource "aws_dms_replication_instance" "main" {
  replication_instance_id    = "dms-aws-dev-01"
  replication_instance_class = "dms.t3.medium"
  allocated_storage          = 50
  multi_az                   = false
  vpc_security_group_ids     = [var.dms_security_group_id]
  replication_subnet_group_id = var.dms_subnet_group_id

  tags = {
    Name        = "DMS-AWS-DEV-01"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "aws_dms_endpoint" "source" {
  endpoint_id   = "src-aws-dev-01"
  endpoint_type = "source"
  engine_name   = "postgres"
  server_name   = var.source_db_host
  port          = 5432
  database_name = var.source_db_name
  username      = var.source_db_user
  password      = var.source_db_password
}

resource "aws_dms_endpoint" "target" {
  endpoint_id   = "tgt-aws-dev-01"
  endpoint_type = "target"
  engine_name   = "postgres"
  server_name   = var.target_db_host
  port          = 5432
  database_name = var.target_db_name
  username      = var.target_db_user
  password      = var.target_db_password
}
