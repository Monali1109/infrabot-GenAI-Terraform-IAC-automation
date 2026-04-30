# ── Compute: gmojzgf6v (prod) ─────────────────────────────────
variable "gmojzgf6v_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}
variable "gmojzgf6v_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}
variable "gmojzgf6v_volume_size" {
  description = "Root volume size GB"
  type        = number
  default     = 23
}
variable "gmojzgf6v_vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "VPC-5428405"
}
variable "gmojzgf6v_subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
  default     = ["subnet-xxxxxxxx"]
}

data "aws_ami" "gmojzgf6v_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter { name = "name"; values = ["Windows_Server-2022-English-Full-Base-*"] }
  filter { name = "virtualization-type"; values = ["hvm"] }
}

resource "aws_instance" "gmojzgf6v" {
  count                  = var.gmojzgf6v_count
  ami                    = data.aws_ami.gmojzgf6v_ami.id
  instance_type          = var.gmojzgf6v_instance_type
  subnet_id              = var.gmojzgf6v_subnet_ids[count.index % length(var.gmojzgf6v_subnet_ids)]
  vpc_security_group_ids = [aws_security_group.gmojzgf6v_sg.id]

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }
  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.gmojzgf6v_volume_size
    encrypted             = true
    delete_on_termination = true
  }
  tags = { Name = "webdv01-${count.index}", Environment = "prod", Generation = "gmojzgf6v" }
}

resource "aws_security_group" "gmojzgf6v_sg" {
  name        = "webdv01-gmojzgf6v-sg"
  description = "Auto-created SG for gmojzgf6v"
  vpc_id      = var.gmojzgf6v_vpc_id
  egress {
    from_port   = 0; to_port = 0; protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "webdv01-gmojzgf6v-sg" }
}

output "gmojzgf6v_ids"        { value = aws_instance.gmojzgf6v[*].id }
output "gmojzgf6v_public_ips" { value = aws_instance.gmojzgf6v[*].public_ip }

# ── Firewall: gmolqk2up (prod) ──────────────────────────────────
variable "gmolqk2up_vpc_id" {
  description = "VPC ID for security group"
  type        = string
  default     = "vpc-xxxxxxxx"
}

resource "aws_security_group" "gmolqk2up_sg" {
  name        = "${var.project_name}-gmolqk2up-sg"
  description = "Firewall rules for gmolqk2up (prod)"
  vpc_id      = var.gmolqk2up_vpc_id

  ingress {
    description = "gmolqk2up ingress — source 10.10.0.0/0"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/0"]
  }
  egress {
    description = "gmolqk2up egress — destination 20.10.0.0/0"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["20.10.0.0/0"]
  }
  tags = { Name = "${var.project_name}-gmolqk2up-sg", Environment = "prod" }
}

output "gmolqk2up_sg_id"  { value = aws_security_group.gmolqk2up_sg.id }
output "gmolqk2up_sg_arn" { value = aws_security_group.gmolqk2up_sg.arn }