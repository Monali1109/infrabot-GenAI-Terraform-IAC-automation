resource "aws_db_subnet_group" "main" {
  name       = "dbsg-aws-dev-01"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name        = "DBSG-AWS-DEV-01"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "aws_db_instance" "main" {
  identifier              = "rds-aws-dev-01"
  engine                  = "postgres"
  engine_version          = "15.3"
  instance_class          = "db.t3.medium"
  allocated_storage       = 20
  max_allocated_storage   = 100
  db_name                 = "appdb"
  username                = "dbadmin"
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [var.db_security_group_id]
  multi_az                = false
  storage_encrypted       = true
  backup_retention_period = 7
  deletion_protection     = false
  skip_final_snapshot     = true

  tags = {
    Name        = "RDS-AWS-DEV-01"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
