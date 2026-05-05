# ── Firewall: gmosm77g2 (prod) ──────────────────────────────────
variable "gmosm77g2_vpc_id" {
  description = "VPC ID for security group"
  type        = string
  default     = "vpc-xxxxxxxx"
}

resource "aws_security_group" "gmosm77g2_sg" {
  name        = "${var.project_name}-gmosm77g2-sg"
  description = "Firewall rules for gmosm77g2 (prod)"
  vpc_id      = var.gmosm77g2_vpc_id

  ingress {
    description = "gmosm77g2 ingress — source 10.20.0.23/32"
    from_port   = 43
    to_port     = 43
    protocol    = "tcp"
    cidr_blocks = ["10.20.0.23/32"]
  }
  egress {
    description = "gmosm77g2 egress — destination 198.168.20.7/32"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["198.168.20.7/32"]
  }
  tags = { Name = "${var.project_name}-gmosm77g2-sg", Environment = "prod" }
}

output "gmosm77g2_sg_id"  { value = aws_security_group.gmosm77g2_sg.id }
output "gmosm77g2_sg_arn" { value = aws_security_group.gmosm77g2_sg.arn }