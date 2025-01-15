include {
  path = find_in_parent_folders()
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "../..//modules/security"

  extra_arguments "custom_vars" {
    commands = [
      "apply",
      "plan",
      "import",
      "push",
      "refresh"
    ]
  }
}

inputs = merge(
  local.env_vars.locals,
  {
    # Security Scanner Configuration
    scan_configs = {
      "web-security-scan" = {
        starting_urls    = ["https://example.com"]
        target_platforms = ["COMPUTE"]
        schedule_time    = "2024-01-01T00:00:00Z"
        schedule_interval = "EVERY_7_DAYS"
      }
    }

    # Security Health Analytics Configuration
    custom_modules = {
      "custom-security-module" = {
        description = "Custom security module for compliance"
        finding_configs = [{
          finding_class_name = "OPEN_FIREWALL"
          severity          = "HIGH"
          resource_type     = "compute.googleapis.com/Firewall"
          category         = "NETWORK_SECURITY"
        }]
      }
    }

    # Organization Policy Configuration
    organization_policies = {
      "compute.disableSerialPortAccess" = {
        name = "compute.disableSerialPortAccess"
        rules = [{
          enforce = true
        }]
      }
    }

    # Access Context Configuration
    access_levels = {
      "trusted-access" = {
        title = "trusted_access"
        basic = {
          conditions = [{
            ip_subnetworks = ["10.0.0.0/8"]
          }]
        }
      }
    }

    # Binary Authorization Configuration
    policy_config = {
      global_policy_evaluation_mode = "ENABLE"
      default_admission_rule = {
        evaluation_mode  = "ALWAYS_DENY"
        enforcement_mode = "ENFORCED_BLOCK_AND_AUDIT_LOG"
      }
    }

    # Asset Inventory Configuration
    feed_config = {
      asset_names = ["projects/${local.env_vars.locals.project_id}"]
      asset_types = ["compute.googleapis.com/Instance"]
      content_type = "RESOURCE"
    }

    # IAP Configuration
    oauth_config = {
      display_name = "My Application"
      brand_id     = "my-brand"
    }

    # Additional Security Settings
    security_settings = {
      enable_os_login             = true
      enable_shielded_vm         = true
      enable_vpc_service_controls = true
      allowed_regions            = ["us-central1", "us-west1"]
    }

    # Monitoring and Alerting
    monitoring_config = {
      notification_channels = {
        email = ["alerts@example.com"]
        slack = ["#gcp-alerts"]
      }
      alert_policies = {
        cpu_utilization = 0.8
        memory_utilization = 0.8
      }
    }
  }
)
