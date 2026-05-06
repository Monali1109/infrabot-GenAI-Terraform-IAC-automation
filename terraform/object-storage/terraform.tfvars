# Bucket name is defined in main.tf as: s3-aws-prod-data-01
# No required variables — defaults applied from variables.tf


# ── prod environment ─────────────────────────────────────────
aws_region        = "us-east-1"
tf_state_bucket   = "my-tfstate-prod"
project_name      = "myproject"

# ── Generation gmottvyce ──
gmottvyce_versioning = "Enabled"
gmottvyce_encryption = "SSE-S3 (AES256)"
gmottvyce_access_control = "private"
gmottvyce_lifecycle_rule = "Move to Glacier after 90d"
gmottvyce_bucket_name = "my-app-data-prod-2026"
gmottvyce_region = "us-east-1"
gmottvyce_tags = "Project=MyApp,Environment=prod,ManagedBy=TerraformGenerate"
gmottvyce_cidr = "0.0.0.0/0"
gmottvyce_access = "Deny"
gmottvyce_service_access = "S3"