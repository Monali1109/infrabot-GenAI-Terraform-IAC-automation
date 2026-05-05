resource "google_storage_bucket" "main" {
  name          = "gcs-gcp-prod-data-01"
  location      = var.region
  force_destroy = false

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  labels = {
    environment = "prod"
    managed_by  = "terraform"
  }
}
