provider "google" {
  project = var.project_id
  region  = var.region
}

module "gcs_bucket" {
  source = "../../../modules/storage/gcs"

  project_id = var.project_id
  name       = "my-unique-bucket-name"
  location   = var.region

  storage_class = "STANDARD"
  versioning    = true

  lifecycle_rules = [
    {
      action = {
        type = "SetStorageClass"
        storage_class = "NEARLINE"
      }
      condition = {
        age = 60
        with_state = "LIVE"
      }
    },
    {
      action = {
        type = "Delete"
      }
      condition = {
        age = 365
      }
    }
  ]

  cors = [
    {
      origin          = ["http://example.com"]
      method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
      response_header = ["*"]
      max_age_seconds = 3600
    }
  ]

  labels = {
    environment = "production"
    team        = "data"
  }
}
