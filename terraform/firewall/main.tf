resource "aws_security_group" "app_sg" {
  name        = "SG_AWS_APP_DEV-01"
  description = "App server security group for dev"
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
    Name        = "SG_AWS_APP_DEV-01"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "SG_AWS_DB_DEV-01"
  description = "DB security group for dev"
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
    Name        = "SG_AWS_DB_DEV-01"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}


# ── Firewall: gmowqdugm (dev) ──────────────────────────────────
variable "gmowqdugm_vpc_id" {
  description = "VPC ID for security group"
  type        = string
  default     = "vpc-xxxxxxxx" # TODO: Replace with your custom VPC ID (e.g. vpc-0a1b2c3d4e5f)
}
variable "gmowqdugm_subnet_id" {
  description = "Subnet ID within the VPC"
  type        = string
  default     = "subnet-xxxxxxxx" # TODO: Replace with your custom Subnet ID (e.g. subnet-0a1b2c3d)
}

resource "aws_security_group" "gmowqdugm_sg" {
  name        = "${var.project_name}-gmowqdugm-sg"
  description = "Firewall rules for gmowqdugm (dev)"
  vpc_id      = var.gmowqdugm_vpc_id

  egress {
    description = "gmowqdugm egress — destination 198.168.20.73/32"
    from_port   = 56
    to_port     = 56
    protocol    = "tcp"
    cidr_blocks = ["198.168.20.73/32"]
  }
  tags = { Name = "${var.project_name}-gmowqdugm-sg", Environment = "dev" }
}

output "gmowqdugm_sg_id"  { value = aws_security_group.gmowqdugm_sg.id }
output "gmowqdugm_sg_arn" { value = aws_security_group.gmowqdugm_sg.arn }