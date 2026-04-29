terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
  backend "s3" {
    bucket = var.tf_state_bucket
    key    = "dev/terraform.tfstate"
    region = var.aws_region
  }
}
provider "aws" {
  region = var.aws_region
  default_tags { tags = { Environment = "dev", ManagedBy = "Terraform" } }
}