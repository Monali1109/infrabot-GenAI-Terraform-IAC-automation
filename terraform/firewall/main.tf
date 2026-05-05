resource "aws_security_group" "app_sg" {
  name        = "SG_AWS_APP_PROD-01"
  description = "App server security group for prod"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
    description = "SSH admin"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "SG_AWS_APP_PROD-01"
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "SG_AWS_DB_PROD-01"
  description = "DB security group for prod"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
    description     = "PostgreSQL from app tier"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "SG_AWS_DB_PROD-01"
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}
