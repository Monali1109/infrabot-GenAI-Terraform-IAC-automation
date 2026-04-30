# ── Compute: gmol7ciwz (dev) ─────────────────────────────────
variable "gmol7ciwz_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}
variable "gmol7ciwz_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}
variable "gmol7ciwz_volume_size" {
  description = "Root volume size GB"
  type        = number
  default     = 50
}
variable "gmol7ciwz_vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "vpc-xxxxxxxx"
}
variable "gmol7ciwz_subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
  default     = ["subnet-xxxxxxxx"]
}

data "aws_ami" "gmol7ciwz_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter { name = "name"; values = ["al2023-ami-*-x86_64"] }
  filter { name = "virtualization-type"; values = ["hvm"] }
}

resource "aws_instance" "gmol7ciwz" {
  count                  = var.gmol7ciwz_count
  ami                    = data.aws_ami.gmol7ciwz_ami.id
  instance_type          = var.gmol7ciwz_instance_type
  subnet_id              = var.gmol7ciwz_subnet_ids[count.index % length(var.gmol7ciwz_subnet_ids)]
  vpc_security_group_ids = [aws_security_group.gmol7ciwz_sg.id]

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }
  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.gmol7ciwz_volume_size
    encrypted             = true
    delete_on_termination = true
  }
  tags = { Name = "gmol7ciwz-${count.index}", Environment = "dev", Generation = "gmol7ciwz" }
}

resource "aws_security_group" "gmol7ciwz_sg" {
  name        = "gmol7ciwz-gmol7ciwz-sg"
  description = "Auto-created SG for gmol7ciwz"
  vpc_id      = var.gmol7ciwz_vpc_id
  egress {
    from_port   = 0; to_port = 0; protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "gmol7ciwz-gmol7ciwz-sg" }
}

output "gmol7ciwz_ids"        { value = aws_instance.gmol7ciwz[*].id }
output "gmol7ciwz_public_ips" { value = aws_instance.gmol7ciwz[*].public_ip }