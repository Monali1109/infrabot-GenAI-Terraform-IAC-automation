terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.29.1"
    }
  }
}
provider "google" {
  # Configuration options
  region  = var.region
  project = var.project_id
}