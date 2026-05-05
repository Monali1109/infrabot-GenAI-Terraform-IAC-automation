region  = "us-central1"

# GCP uses VPC self_link — get it with:
#   gcloud compute networks describe vpc-gcp-test-01 --format='value(selfLink)'
network_id = "projects/REPLACE_PROJECT_ID/global/networks/vpc-gcp-test-01"

# IMPORTANT: Do not commit real passwords — use Secret Manager in production
db_password = "REPLACE_WITH_SECURE_PASSWORD"
