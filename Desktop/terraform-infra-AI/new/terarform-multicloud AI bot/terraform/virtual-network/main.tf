resource "aws_vpc" "main" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "VPC_AWS_DEV-01"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "aws_subnet" "app" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.1.0/24"
  availability_zone = var.availability_zone

  tags = {
    Name        = "SUBNET_AWS_APP_DEV-01"
    Environment = "dev"
  }
}

resource "aws_subnet" "db" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.2.0/24"
  availability_zone = var.availability_zone

  tags = {
    Name        = "SUBNET_AWS_DB_DEV-01"
    Environment = "dev"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "IGW_AWS_DEV-01"
    Environment = "dev"
  }
}
