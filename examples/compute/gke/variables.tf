variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
  default = "dev-project-2025"
}

variable "region" {
  description = "The region where resources will be deployed"
  type        = string
  default = "us-central1"
}
