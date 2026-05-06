resource "aws_s3_bucket" "main" {
  bucket = "s3-aws-dev-data-01"

  tags = {
    Name        = "S3-AWS-DEV-DATA-01"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# ── S3 Bucket: gmottgw7t (dev) ─────────────────────────────────
resource "aws_s3_bucket" "gmottgw7t" {
  bucket = "${var.project_name}-gmottgw7t-dev"
  force_destroy = false

  tags = { environment = "dev", generation = "gmottgw7t", managed_by = "terraform" }
}

output "gmottgw7t_id" { value = aws_s3_bucket.gmottgw7t.id }