resource "aws_instance" "awsapppd01" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "c5.xlarge"
  subnet_id     = var.subnet_id
  private_ip    = "10.10.1.10"
  key_name      = var.key_name

  tags = {
    Name        = "AWSAPPPD01"
    Environment = "prod"
    Role        = "app"
    ManagedBy   = "Terraform"
  }
}

resource "aws_instance" "awsdbpd01" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "m5.2xlarge"
  subnet_id     = var.subnet_id
  private_ip    = "10.10.2.11"
  key_name      = var.key_name

  tags = {
    Name        = "AWSDBPD01"
    Environment = "prod"
    Role        = "db"
    ManagedBy   = "Terraform"
  }
}
