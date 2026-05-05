variable "zone" {
  type        = string
  default     = "us-central1-a"
  description = "GCP zone"
}

variable "subnetwork" {
  type        = string
  description = "Subnetwork self-link"
}

variable "project_id" {
  type        = string
  default     = "clinical_apps_prod"
  description = "GCP project ID"
}
