resource "aws_route53_zone" "main" {
  name    = "prod.example.internal"
  comment = "Private DNS zone for prod environment"

  vpc {
    vpc_id = var.vpc_id
  }

  tags = {
    Name        = "DNS-AWS-PROD-01"
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}

resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "app.prod.example.internal"
  type    = "A"
  ttl     = 300
  records = [var.app_private_ip]
}

resource "aws_route53_record" "db" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "db.prod.example.internal"
  type    = "A"
  ttl     = 300
  records = [var.db_private_ip]
}
