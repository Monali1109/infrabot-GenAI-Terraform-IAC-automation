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


# ── Compute: gmosvqdss (dev) ─────────────────────────────────
variable "gmosvqdss_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "r5.xlarge"
}
variable "gmosvqdss_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}
variable "gmosvqdss_volume_size" {
  description = "Root volume size GB"
  type        = number
  default     = 100
}
variable "gmosvqdss_vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "vpc-xxxxxxxx"
}
variable "gmosvqdss_subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
  default     = ["subnet-xxxxxxxx"]
}

data "aws_ami" "gmosvqdss_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter { name = "name"; values = ["Windows_Server-2022-English-Full-Base-*"] }
  filter { name = "virtualization-type"; values = ["hvm"] }
}

resource "aws_instance" "gmosvqdss" {
  count                  = var.gmosvqdss_count
  ami                    = data.aws_ami.gmosvqdss_ami.id
  instance_type          = var.gmosvqdss_instance_type
  subnet_id              = var.gmosvqdss_subnet_ids[count.index % length(var.gmosvqdss_subnet_ids)]
  vpc_security_group_ids = [aws_security_group.gmosvqdss_sg.id]

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }
  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.gmosvqdss_volume_size
    encrypted             = true
    delete_on_termination = true
  }
  tags = { Name = "AWSDBPD02-${count.index}", Environment = "dev", Generation = "gmosvqdss" }
}

resource "aws_security_group" "gmosvqdss_sg" {
  name        = "AWSDBPD02-gmosvqdss-sg"
  description = "Auto-created SG for gmosvqdss"
  vpc_id      = var.gmosvqdss_vpc_id
  egress {
    from_port   = 0; to_port = 0; protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "AWSDBPD02-gmosvqdss-sg" }
}

output "gmosvqdss_ids"        { value = aws_instance.gmosvqdss[*].id }
output "gmosvqdss_public_ips" { value = aws_instance.gmosvqdss[*].public_ip }