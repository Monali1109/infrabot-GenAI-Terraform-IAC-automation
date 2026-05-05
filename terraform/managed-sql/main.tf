resource "aws_db_subnet_group" "main" {
  name       = "dbsg-aws-prod-01"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name        = "DBSG-AWS-PROD-01"
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}

resource "aws_db_instance" "main" {
  identifier              = "rds-aws-prod-01"
  engine                  = "postgres"
  engine_version          = "15.3"
  instance_class          = "db.m5.large"
  allocated_storage       = 100
  max_allocated_storage   = 500
  db_name                 = "appdb"
  username                = "dbadmin"
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [var.db_security_group_id]
  multi_az                = true
  storage_encrypted       = true
  backup_retention_period = 30
  deletion_protection     = true
  skip_final_snapshot     = false

  tags = {
    Name        = "RDS-AWS-PROD-01"
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}
