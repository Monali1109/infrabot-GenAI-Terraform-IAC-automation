# Bucket name is defined in main.tf as: s3-aws-dev-data-01
# No required variables — defaults applied from variables.tf


# ── dev environment ─────────────────────────────────────────
aws_region        = "us-east-1"
tf_state_bucket   = "my-tfstate-dev"
project_name      = "myproject"

# ── Generation gmottgw7t ──
gmottgw7t_versioning = "Enabled"
gmottgw7t_encryption = "SSE-S3 (AES256)"
gmottgw7t_access_control = "private"
gmottgw7t_lifecycle_rule = "Move to Glacier after 90d"
gmottgw7t_bucket_name = "my-app-data-dev-2026"
gmottgw7t_region = "us-east-1"
gmottgw7t_tags = "Project=MyApp,Environment=dev,ManagedBy=TerraformGenerate"
gmottgw7t_cidr = "0.0.0.0/0"
gmottgw7t_access = "Deny"
gmottgw7t_service_access = "S3"