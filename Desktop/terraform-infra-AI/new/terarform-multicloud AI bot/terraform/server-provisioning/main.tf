resource "aws_instance" "awsappdv01" {
  ami           = "ami-0a91cd140a1fc148a"
  instance_type = "c5.xlarge"
  subnet_id     = var.subnet_id
  private_ip    = "10.20.1.10"
  key_name      = var.key_name

  tags = {
    Name        = "AWSAPPDV01"
    Environment = "dev"
    Role        = "app"
    ManagedBy   = "Terraform"
  }
}

resource "aws_instance" "awsdbdv01" {
  ami           = "ami-0a91cd140a1fc148a"
  instance_type = "m5.2xlarge"
  subnet_id     = var.subnet_id
  private_ip    = "10.20.2.11"
  key_name      = var.key_name

  tags = {
    Name        = "AWSDBDV01"
    Environment = "dev"
    Role        = "db"
    ManagedBy   = "Terraform"
  }
}
