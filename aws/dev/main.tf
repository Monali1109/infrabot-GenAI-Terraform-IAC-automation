# ── Compute: gmol7v17n (dev) ─────────────────────────────────
variable "gmol7v17n_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}
variable "gmol7v17n_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}
variable "gmol7v17n_volume_size" {
  description = "Root volume size GB"
  type        = number
  default     = 50
}
variable "gmol7v17n_vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "vpc-xxxxxxxx"
}
variable "gmol7v17n_subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
  default     = ["subnet-xxxxxxxx"]
}

data "aws_ami" "gmol7v17n_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter { name = "name"; values = ["al2023-ami-*-x86_64"] }
  filter { name = "virtualization-type"; values = ["hvm"] }
}

resource "aws_instance" "gmol7v17n" {
  count                  = var.gmol7v17n_count
  ami                    = data.aws_ami.gmol7v17n_ami.id
  instance_type          = var.gmol7v17n_instance_type
  subnet_id              = var.gmol7v17n_subnet_ids[count.index % length(var.gmol7v17n_subnet_ids)]
  vpc_security_group_ids = [aws_security_group.gmol7v17n_sg.id]

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }
  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.gmol7v17n_volume_size
    encrypted             = true
    delete_on_termination = true
  }
  tags = { Name = "gmol7v17n-${count.index}", Environment = "dev", Generation = "gmol7v17n" }
}

resource "aws_security_group" "gmol7v17n_sg" {
  name        = "gmol7v17n-gmol7v17n-sg"
  description = "Auto-created SG for gmol7v17n"
  vpc_id      = var.gmol7v17n_vpc_id
  egress {
    from_port   = 0; to_port = 0; protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "gmol7v17n-gmol7v17n-sg" }
}

output "gmol7v17n_ids"        { value = aws_instance.gmol7v17n[*].id }
output "gmol7v17n_public_ips" { value = aws_instance.gmol7v17n[*].public_ip }


# ── Firewall: gmolqasay (dev) ──────────────────────────────────
variable "gmolqasay_vpc_id" {
  description = "VPC ID for security group"
  type        = string
  default     = "vpc-xxxxxxxx"
}

resource "aws_security_group" "gmolqasay_sg" {
  name        = "${var.project_name}-gmolqasay-sg"
  description = "Firewall rules for gmolqasay (dev)"
  vpc_id      = var.gmolqasay_vpc_id

  ingress {
    description = "gmolqasay ingress — source 10.20.0.0/0"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.20.0.0/0"]
  }
  egress {
    description = "gmolqasay egress — destination 197.65.0.0/0"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["197.65.0.0/0"]
  }
  tags = { Name = "${var.project_name}-gmolqasay-sg", Environment = "dev" }
}

output "gmolqasay_sg_id"  { value = aws_security_group.gmolqasay_sg.id }
output "gmolqasay_sg_arn" { value = aws_security_group.gmolqasay_sg.arn }