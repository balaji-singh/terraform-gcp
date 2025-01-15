provider "google" {
  project = var.project_id
  region  = var.region
}

module "iap" {
  source = "../../../modules/security/iap"

  project_id = var.project_id
  create_brand = true
  support_email = "support@example.com"
  application_title = "Corporate Application Suite"

  # OAuth Clients
  oauth_clients = {
    "web_client" = {
      display_name = "Web Application Client"
    },
    "api_client" = {
      display_name = "API Service Client"
    }
  }

  # Backend Service IAM
  backend_service_iam_bindings = {
    "app_backend" = {
      backend_service = "projects/${var.project_id}/global/backendServices/app-backend"
      role           = "roles/iap.httpsResourceAccessor"
      members        = [
        "group:developers@example.com",
        "serviceAccount:ci-cd@${var.project_id}.iam.gserviceaccount.com"
      ]
    }
  }

  # Web IAM
  web_iam_bindings = {
    "web_admin" = {
      role    = "roles/iap.admin"
      members = ["group:security-admins@example.com"]
    }
  }

  # App Engine IAM
  app_engine_iam_bindings = {
    "app_engine_access" = {
      app_id  = var.project_id
      role    = "roles/iap.httpsResourceAccessor"
      members = ["group:app-users@example.com"]
    }
  }

  # Compute IAM
  compute_iam_bindings = {
    "compute_access" = {
      role    = "roles/iap.tunnelResourceAccessor"
      members = ["group:ops-team@example.com"]
    }
  }

  # Tunnel Instance IAM
  tunnel_instance_iam_bindings = {
    "bastion_access" = {
      zone     = "us-central1-a"
      instance = "bastion-host"
      role     = "roles/iap.tunnelResourceAccessor"
      members  = ["group:ops-team@example.com"]
    }
  }

  # Backend Service Configs
  backend_service_configs = {
    "app_backend" = {
      backend_service = "projects/${var.project_id}/global/backendServices/app-backend"
      oauth2_client_id = {
        client_id     = "client-id"
        client_secret = "client-secret"
      }
    }
  }
}
