resource "aws_vpc" "main" {
  cidr_block           = "10.30.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "VPC_AWS_TEST-01"
    Environment = "test"
    ManagedBy   = "Terraform"
  }
}

resource "aws_subnet" "app" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.30.1.0/24"
  availability_zone = var.availability_zone

  tags = {
    Name        = "SUBNET_AWS_APP_TEST-01"
    Environment = "test"
  }
}

resource "aws_subnet" "db" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.30.2.0/24"
  availability_zone = var.availability_zone

  tags = {
    Name        = "SUBNET_AWS_DB_TEST-01"
    Environment = "test"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "IGW_AWS_TEST-01"
    Environment = "test"
  }
}
