provider "google" {
  project = var.project_id
  region  = var.region
}

module "cloudsql" {
  source = "../../../modules/databases/cloudsql"

  project_id        = var.project_id
  instance_name     = "my-postgres-db"
  database_version  = "POSTGRES_14"
  region           = var.region

  # Instance configuration
  tier               = "db-custom-2-8192"
  availability_type  = "REGIONAL"
  disk_size          = 50
  disk_type          = "PD_SSD"

  # Backup configuration
  backup_enabled     = true
  binary_log_enabled = false
  backup_start_time  = "23:00"

  # Network configuration
  public_ip_enabled = false
  private_network   = "projects/${var.project_id}/global/networks/my-vpc"
  authorized_networks = [
    {
      name = "office"
      cidr = "10.0.0.0/24"
    }
  ]

  # Database and user configuration
  databases = ["app_db", "analytics_db"]
  users = [
    {
      name     = "app_user"
      password = "changeme123"  # In production, use secrets management
    },
    {
      name     = "analytics_user"
      password = "changeme456"  # In production, use secrets management
    }
  ]

  # Maintenance and monitoring
  maintenance_window_day          = 7
  maintenance_window_hour         = 23
  maintenance_window_update_track = "stable"
  query_insights_enabled         = true
}
