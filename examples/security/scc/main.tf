provider "google" {
  project = var.project_id
  region  = var.region
}

module "scc" {
  source = "../../../modules/security/scc"

  organization_id = var.organization_id
  enable_organization_settings = true
  enable_asset_discovery      = true
  
  # Sources
  sources = {
    "custom-source" = {
      display_name = "Custom Security Source"
      description  = "Custom source for security findings"
    }
  }

  # Notification Configs
  notification_configs = {
    "high-severity" = {
      description  = "Notifications for high severity findings"
      pubsub_topic = "projects/${var.project_id}/topics/scc-notifications"
      filter       = "severity = \"HIGH\" OR severity = \"CRITICAL\""
    }
  }

  # Findings
  findings = {
    "critical-finding" = {
      source_name    = "custom-source"
      parent        = "organizations/${var.organization_id}"
      resource_name = "//compute.googleapis.com/projects/${var.project_id}/zones/us-central1-a/instances/example-instance"
      state         = "ACTIVE"
      category      = "VULNERABILITY"
      event_time    = "2024-01-01T00:00:00Z"
      severity      = "CRITICAL"
      security_marks = {
        priority = "p0"
        type     = "external_attack"
      }
      source_properties = {
        "compliance_standards" = "HIPAA"
        "attack_vector"       = "internet_exposed"
      }
    }
  }

  # Mute Configs
  mute_configs = {
    "low-severity" = {
      parent      = "organizations/${var.organization_id}"
      description = "Mute low severity findings"
      filter      = "severity = \"LOW\""
    }
  }

  # Source IAM Bindings
  source_iam_bindings = {
    "source-viewer" = {
      source_name = "custom-source"
      role        = "roles/securitycenter.sourcesViewer"
      members     = ["group:security-team@example.com"]
    }
  }

  # Custom Modules
  custom_modules = {
    "custom-scanner" = {
      display_name     = "Custom Security Scanner"
      custom_config    = jsonencode({
        scannerConfig = {
          scanInterval = "DAILY"
          targetResources = ["projects/*"]
        }
      })
      enablement_state = "ENABLED"
    }
  }
}
