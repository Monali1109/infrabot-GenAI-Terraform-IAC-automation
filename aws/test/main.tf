# ── Compute: gmol9tzxv (test) ─────────────────────────────────
variable "gmol9tzxv_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}
variable "gmol9tzxv_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}
variable "gmol9tzxv_volume_size" {
  description = "Root volume size GB"
  type        = number
  default     = 50
}
variable "gmol9tzxv_vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "vpc-xxxxxxxx"
}
variable "gmol9tzxv_subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
  default     = ["subnet-xxxxxxxx"]
}

data "aws_ami" "gmol9tzxv_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter { name = "name"; values = ["al2023-ami-*-x86_64"] }
  filter { name = "virtualization-type"; values = ["hvm"] }
}

resource "aws_instance" "gmol9tzxv" {
  count                  = var.gmol9tzxv_count
  ami                    = data.aws_ami.gmol9tzxv_ami.id
  instance_type          = var.gmol9tzxv_instance_type
  subnet_id              = var.gmol9tzxv_subnet_ids[count.index % length(var.gmol9tzxv_subnet_ids)]
  vpc_security_group_ids = [aws_security_group.gmol9tzxv_sg.id]

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }
  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.gmol9tzxv_volume_size
    encrypted             = true
    delete_on_termination = true
  }
  tags = { Name = "RD01-${count.index}", Environment = "test", Generation = "gmol9tzxv" }
}

resource "aws_security_group" "gmol9tzxv_sg" {
  name        = "RD01-gmol9tzxv-sg"
  description = "Auto-created SG for gmol9tzxv"
  vpc_id      = var.gmol9tzxv_vpc_id
  egress {
    from_port   = 0; to_port = 0; protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "RD01-gmol9tzxv-sg" }
}

output "gmol9tzxv_ids"        { value = aws_instance.gmol9tzxv[*].id }
output "gmol9tzxv_public_ips" { value = aws_instance.gmol9tzxv[*].public_ip }