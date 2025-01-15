provider "google" {
  project = var.project_id
  region  = var.region
}

module "cloud_function" {
  source = "../../../modules/compute/functions"

  project_id   = var.project_id
  function_name = "my-function"
  description  = "Example Cloud Function"
  region       = var.region

  runtime     = "python39"
  entry_point = "process_event"
  source_dir  = "./src"
  archive_path = "/tmp/function.zip"

  environment_variables = {
    ENV = "production"
    API_KEY = "secret-key"  # In production, use Secret Manager
  }

  secret_environment_variables = [
    {
      key        = "DB_PASSWORD"
      project_id = var.project_id
      secret     = "my-secret"
      version    = "latest"
    }
  ]

  event_type = "google.cloud.storage.object.v1.finalized"
  event_filters = [
    {
      attribute = "bucket"
      value     = "my-bucket"
    }
  ]

  service_account_email = "my-function@${var.project_id}.iam.gserviceaccount.com"
  
  max_instance_count = 10
  available_memory  = "512M"
  timeout_seconds   = 120

  labels = {
    environment = "production"
    team        = "platform"
  }
}
