provider "google" {
  project = var.project_id
  region  = var.region
}

module "load_balancer" {
  source = "../../../modules/networking/load_balancer"

  project_id = var.project_id
  name       = "example-lb"

  create_address = true
  load_balancing_scheme = "EXTERNAL"

  # Backend configuration
  backend_protocol = "HTTP"
  backend_port_name = "http"
  backend_timeout_sec = 30

  # Enable CDN
  enable_cdn = true
  cdn_cache_mode = "CACHE_ALL_STATIC"
  cdn_client_ttl = 3600
  cdn_default_ttl = 3600
  cdn_max_ttl = 86400

  # Backend groups
  backend_groups = [
    {
      group           = "projects/${var.project_id}/zones/us-central1-a/instanceGroups/app-group-1"
      balancing_mode  = "UTILIZATION"
      capacity_scaler = 1.0
    }
  ]

  # Additional backend services
  additional_backend_services = {
    "api" = {
      protocol     = "HTTP"
      port_name    = "http"
      timeout_sec  = 30
      enable_cdn   = false
      backend_groups = [
        {
          group           = "projects/${var.project_id}/zones/us-central1-a/instanceGroups/api-group-1"
          balancing_mode  = "UTILIZATION"
          capacity_scaler = 1.0
        }
      ]
    }
  }

  # URL mapping rules
  host_rules = [
    {
      hosts        = ["example.com"]
      path_matcher = "main"
    }
  ]

  path_rules = {
    "main" = [
      {
        paths   = ["/api/*"]
        service = "api"
      }
    ]
  }

  # Health check configuration
  health_check_interval_sec = 5
  health_check_timeout_sec = 5
  health_check_port = 80
  health_check_path = "/health"
}
