terraform {
  required_version = ">= 1.5"
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.0" }
  }
  backend "gcs" {
    bucket = var.tf_state_bucket
    prefix = "test/terraform"
  }
}
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}