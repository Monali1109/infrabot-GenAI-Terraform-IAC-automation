resource "aws_route53_zone" "main" {
  name    = "dev.example.internal"
  comment = "Private DNS zone for dev environment"

  vpc {
    vpc_id = var.vpc_id
  }

  tags = {
    Name        = "DNS-AWS-DEV-01"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "app.dev.example.internal"
  type    = "A"
  ttl     = 300
  records = [var.app_private_ip]
}

resource "aws_route53_record" "db" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "db.dev.example.internal"
  type    = "A"
  ttl     = 300
  records = [var.db_private_ip]
}
