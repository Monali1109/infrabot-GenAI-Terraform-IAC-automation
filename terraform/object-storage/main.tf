resource "aws_s3_bucket" "main" {
  bucket = "s3-aws-prod-data-01"

  tags = {
    Name        = "S3-AWS-PROD-DATA-01"
    Environment = "prod"
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


# ── S3 Bucket: gmottvyce (prod) ─────────────────────────────────
resource "aws_s3_bucket" "gmottvyce" {
  bucket = "${var.project_name}-gmottvyce-prod"
  force_destroy = false

  tags = { environment = "prod", generation = "gmottvyce", managed_by = "terraform" }
}

output "gmottvyce_id" { value = aws_s3_bucket.gmottvyce.id }