/**
 * Example of using multiple security modules together
 */

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Organization Policy Module
module "org_policy" {
  source = "../../modules/security/org_policy"

  organization_id = var.organization_id
  project_id     = var.project_id

  organization_policies = {
    "compute.disableSerialPortAccess" = {
      name = "compute.disableSerialPortAccess"
      rules = [{
        enforce = true
      }]
    }
    "compute.restrictVpcPeering" = {
      name = "compute.restrictVpcPeering"
      rules = [{
        enforce = true
      }]
    }
  }

  project_policies = {
    "compute.requireOsLogin" = {
      boolean_policy = {
        enforced = true
      }
    }
  }
}

# Security Scanner Module
module "security_scanner" {
  source = "../../modules/security/security_scanner"

  project_id = var.project_id

  scan_configs = {
    "web-security-scan" = {
      starting_urls    = ["https://example.com"]
      target_platforms = ["COMPUTE"]
      schedule_time    = "2024-01-01T00:00:00Z"
      schedule_interval = "EVERY_7_DAYS"
      export_to_security_command_center = {
        enable = true
        filter = ""
      }
    }
  }
}

# Security Health Analytics Module
module "security_health" {
  source = "../../modules/security/health_analytics"

  organization_id = var.organization_id

  custom_modules = {
    "custom-security-module" = {
      description = "Custom security module for compliance"
      finding_configs = [{
        finding_class_name = "OPEN_FIREWALL"
        severity          = "HIGH"
        resource_type     = "compute.googleapis.com/Firewall"
        category         = "NETWORK_SECURITY"
        properties       = {}
      }]
    }
  }

  notification_configs = {
    "security-alerts" = {
      description  = "Security alerts notification config"
      pubsub_topic = "projects/${var.project_id}/topics/security-alerts"
      filter       = "severity = HIGH OR severity = CRITICAL"
    }
  }
}

# Cloud Audit Logs Module
module "audit_logs" {
  source = "../../modules/security/audit_logs"

  project_id = var.project_id
  
  audit_log_config = {
    service = "allServices"
    audit_log_configs = {
      log_type = "DATA_WRITE"
      exempted_members = []
    }
  }
}

# Access Context Manager Module
module "access_context" {
  source = "../../modules/security/access_context"

  organization_id = var.organization_id

  access_levels = {
    "trusted-access" = {
      title = "trusted_access"
      basic = {
        conditions = [{
          ip_subnetworks = ["10.0.0.0/8"]
          required_access_levels = []
        }]
      }
    }
  }
}

# Binary Authorization Module
module "binary_authorization" {
  source = "../../modules/security/binary_authorization"

  project_id = var.project_id

  policy_config = {
    global_policy_evaluation_mode = "ENABLE"
    default_admission_rule = {
      evaluation_mode  = "ALWAYS_DENY"
      enforcement_mode = "ENFORCED_BLOCK_AND_AUDIT_LOG"
    }
  }
}

# Cloud Asset Inventory Module
module "asset_inventory" {
  source = "../../modules/security/asset_inventory"

  project_id = var.project_id
  
  feed_config = {
    asset_names = ["projects/${var.project_id}"]
    asset_types = ["compute.googleapis.com/Instance"]
    content_type = "RESOURCE"
  }
}

# Identity-Aware Proxy Module
module "iap" {
  source = "../../modules/security/iap"

  project_id = var.project_id

  oauth_config = {
    display_name = "My Application"
    brand_id     = "my-brand"
  }
}
