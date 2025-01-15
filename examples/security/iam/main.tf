provider "google" {
  project = var.project_id
  region  = var.region
}

module "iam" {
  source = "../../../modules/security/iam"

  project_id = var.project_id

  # Service Accounts
  service_accounts = {
    "app-sa" = {
      display_name = "Application Service Account"
      description  = "Service account for the application"
      keys = [
        {
          key_id = "key1"
        }
      ]
    }
    "monitoring-sa" = {
      display_name = "Monitoring Service Account"
      description  = "Service account for monitoring"
    }
  }

  # Project IAM Bindings
  project_roles = {
    "roles/monitoring.viewer" = [
      "serviceAccount:monitoring-sa@${var.project_id}.iam.gserviceaccount.com",
    ]
    "roles/storage.objectViewer" = [
      "serviceAccount:app-sa@${var.project_id}.iam.gserviceaccount.com",
    ]
  }

  # Custom Roles
  custom_roles = {
    "customMonitoringRole" = {
      title       = "Custom Monitoring Role"
      description = "Custom role for monitoring"
      permissions = [
        "monitoring.timeSeries.list",
        "monitoring.groups.list",
        "monitoring.alerts.list"
      ]
      stage = "GA"
    }
  }

  # Service Account IAM Bindings
  service_account_bindings = {
    "app-sa-binding" = {
      service_account_id = "app-sa"
      role              = "roles/iam.serviceAccountUser"
      members           = ["user:admin@example.com"]
    }
  }

  # Workload Identity Pools
  workload_identity_pools = {
    "github-pool" = {
      display_name = "GitHub Actions Pool"
      description  = "Identity pool for GitHub Actions"
      disabled     = false
    }
  }

  # Workload Identity Pool Providers
  workload_identity_pool_providers = {
    "github-provider" = {
      pool_id      = "github-pool"
      display_name = "GitHub Actions Provider"
      description  = "Identity provider for GitHub Actions"
      disabled     = false
      attribute_mapping = {
        "google.subject"       = "assertion.sub"
        "attribute.actor"      = "assertion.actor"
        "attribute.repository" = "assertion.repository"
      }
      attribute_condition = "attribute.repository.startsWith(\"myorg/\")"
      oidc_config = {
        allowed_audiences = ["https://github.com/myorg"]
        issuer_uri       = "https://token.actions.githubusercontent.com"
      }
    }
  }
}
