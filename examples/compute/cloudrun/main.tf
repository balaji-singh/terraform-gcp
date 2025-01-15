provider "google" {
  project = var.project_id
  region  = var.region
}

module "cloud_run" {
  source = "../../../modules/compute/cloudrun"

  project_id    = var.project_id
  service_name  = "my-service"
  location      = var.region
  
  container_image = "gcr.io/${var.project_id}/my-app:latest"
  
  cpu_limit    = "1000m"
  memory_limit = "512Mi"
  cpu_idle     = true
  
  environment_variables = {
    ENV      = "production"
    API_URL  = "https://api.example.com"
  }

  volume_mounts = [
    {
      name       = "secrets"
      mount_path = "/secrets"
    }
  ]

  volumes = [
    {
      name         = "secrets"
      secret_name  = "my-secret"
      default_mode = 432
      path         = "config"
      version      = "latest"
      mode         = 256
    }
  ]

  service_account_email = "my-service@${var.project_id}.iam.gserviceaccount.com"
  
  timeout_seconds = 300
  max_instance_request_concurrency = 80
  
  min_instances = 1
  max_instances = 10
}
