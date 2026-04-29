# ── Compute: gmojzmn30 (dev) ─────────────────────────────────
variable "gmojzmn30_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}
variable "gmojzmn30_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}
variable "gmojzmn30_volume_size" {
  description = "Root volume size GB"
  type        = number
  default     = 23
}
variable "gmojzmn30_vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "VPC-5428405"
}
variable "gmojzmn30_subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
  default     = ["subnet-xxxxxxxx"]
}

data "aws_ami" "gmojzmn30_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter { name = "name"; values = ["Windows_Server-2022-English-Full-Base-*"] }
  filter { name = "virtualization-type"; values = ["hvm"] }
}

resource "aws_instance" "gmojzmn30" {
  count                  = var.gmojzmn30_count
  ami                    = data.aws_ami.gmojzmn30_ami.id
  instance_type          = var.gmojzmn30_instance_type
  subnet_id              = var.gmojzmn30_subnet_ids[count.index % length(var.gmojzmn30_subnet_ids)]
  vpc_security_group_ids = [aws_security_group.gmojzmn30_sg.id]

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }
  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.gmojzmn30_volume_size
    encrypted             = true
    delete_on_termination = true
  }
  tags = { Name = "webdv01-${count.index}", Environment = "dev", Generation = "gmojzmn30" }
}

resource "aws_security_group" "gmojzmn30_sg" {
  name        = "webdv01-gmojzmn30-sg"
  description = "Auto-created SG for gmojzmn30"
  vpc_id      = var.gmojzmn30_vpc_id
  egress {
    from_port   = 0; to_port = 0; protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "webdv01-gmojzmn30-sg" }
}

output "gmojzmn30_ids"        { value = aws_instance.gmojzmn30[*].id }
output "gmojzmn30_public_ips" { value = aws_instance.gmojzmn30[*].public_ip }