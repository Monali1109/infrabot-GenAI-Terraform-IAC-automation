resource "aws_instance" "awsapptst01" {
  ami           = "ami-0323c3dd2da7fb37d"
  instance_type = "c5.xlarge"
  subnet_id     = var.subnet_id
  private_ip    = "10.30.1.10"
  key_name      = var.key_name

  tags = {
    Name        = "AWSAPPTST01"
    Environment = "test"
    Role        = "app"
    ManagedBy   = "Terraform"
  }
}

resource "aws_instance" "awsdbtst01" {
  ami           = "ami-0323c3dd2da7fb37d"
  instance_type = "m5.2xlarge"
  subnet_id     = var.subnet_id
  private_ip    = "10.30.2.11"
  key_name      = var.key_name

  tags = {
    Name        = "AWSDBTST01"
    Environment = "test"
    Role        = "db"
    ManagedBy   = "Terraform"
  }
}
