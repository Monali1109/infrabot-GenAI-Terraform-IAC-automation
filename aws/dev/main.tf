# ÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂ Compute: gmol9ls0a (dev) ÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂÃÂ¢ÃÂÃÂ
variable "gmol9ls0a_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}
variable "gmol9ls0a_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}
variable "gmol9ls0a_volume_size" {
  description = "Root volume size GB"
  type        = number
  default     = 100
}
variable "gmol9ls0a_vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "vpc-xxxxxxxx"
}
variable "gmol9ls0a_subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
  default     = ["subnet-xxxxxxxx"]
}

data "aws_ami" "gmol9ls0a_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter { name = "name"; values = ["Windows_Server-2022-English-Full-Base-*"] }
  filter { name = "virtualization-type"; values = ["hvm"] }
}

resource "aws_instance" "gmol9ls0a" {
  count                  = var.gmol9ls0a_count
  ami                    = data.aws_ami.gmol9ls0a_ami.id
  instance_type          = var.gmol9ls0a_instance_type
  subnet_id              = var.gmol9ls0a_subnet_ids[count.index % length(var.gmol9ls0a_subnet_ids)]
  vpc_security_group_ids = [aws_security_group.gmol9ls0a_sg.id]

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }
  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.gmol9ls0a_volume_size
    encrypted             = true
    delete_on_termination = true
  }
  tags = { Name = "myserverw1-${count.index}", Environment = "dev", Generation = "gmol9ls0a" }
}

resource "aws_security_group" "gmol9ls0a_sg" {
  name        = "myserverw1-gmol9ls0a-sg"
  description = "Auto-created SG for gmol9ls0a"
  vpc_id      = var.gmol9ls0a_vpc_id
  egress {
    from_port   = 0; to_port = 0; protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "myserverw1-gmol9ls0a-sg" }
}

output "gmol9ls0a_ids"        { value = aws_instance.gmol9ls0a[*].id }
output "gmol9ls0a_public_ips" { value = aws_instance.gmol9ls0a[*].public_ip }