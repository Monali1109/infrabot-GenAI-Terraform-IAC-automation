# ── Compute: gmol9gebu (dev) ─────────────────────────────────
variable "gmol9gebu_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}
variable "gmol9gebu_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}
variable "gmol9gebu_volume_size" {
  description = "Root volume size GB"
  type        = number
  default     = 50
}
variable "gmol9gebu_vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "vpc-xxxxxxxx"
}
variable "gmol9gebu_subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
  default     = ["subnet-xxxxxxxx"]
}

data "aws_ami" "gmol9gebu_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter { name = "name"; values = ["al2023-ami-*-x86_64"] }
  filter { name = "virtualization-type"; values = ["hvm"] }
}

resource "aws_instance" "gmol9gebu" {
  count                  = var.gmol9gebu_count
  ami                    = data.aws_ami.gmol9gebu_ami.id
  instance_type          = var.gmol9gebu_instance_type
  subnet_id              = var.gmol9gebu_subnet_ids[count.index % length(var.gmol9gebu_subnet_ids)]
  vpc_security_group_ids = [aws_security_group.gmol9gebu_sg.id]

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }
  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.gmol9gebu_volume_size
    encrypted             = true
    delete_on_termination = true
  }
  tags = { Name = "gmol9gebu-${count.index}", Environment = "dev", Generation = "gmol9gebu" }
}

resource "aws_security_group" "gmol9gebu_sg" {
  name        = "gmol9gebu-gmol9gebu-sg"
  description = "Auto-created SG for gmol9gebu"
  vpc_id      = var.gmol9gebu_vpc_id
  egress {
    from_port   = 0; to_port = 0; protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "gmol9gebu-gmol9gebu-sg" }
}

output "gmol9gebu_ids"        { value = aws_instance.gmol9gebu[*].id }
output "gmol9gebu_public_ips" { value = aws_instance.gmol9gebu[*].public_ip }