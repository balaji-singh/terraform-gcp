/**
 * Financial Services Security Composition
 * This composition implements security controls for financial services compliance
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

# Network Security with Enhanced Controls
module "network_security" {
  source = "../../../modules/security/network"

  project_id = var.project_id
  network_name = var.network_name

  subnets = {
    "regulated-subnet" = {
      name = "regulated-subnet"
      ip_cidr_range = "10.0.1.0/24"
      region = var.region
      private_ip_google_access = true
      secondary_ranges = {}
    }
  }

  firewall_rules = {
    "allow-internal" = {
      name = "allow-internal"
      direction = "INGRESS"
      priority = 1000
      ranges = ["10.0.0.0/8"]
      allow = [{
        protocol = "tcp"
        ports = ["443", "8443"]
      }]
    }
    "deny-external" = {
      name = "deny-external"
      direction = "INGRESS"
      priority = 2000
      ranges = ["0.0.0.0/0"]
      deny = [{
        protocol = "all"
      }]
    }
  }
}

# Enhanced Cloud Armor Security
module "cloud_armor" {
  source = "../../../modules/security/cloud_armor"

  project_id = var.project_id

  security_policies = {
    "financial-waf" = {
      description = "Financial services WAF policy"
      type = "CLOUD_ARMOR"
      rules = [
        {
          action = "deny(403)"
          priority = 1000
          description = "Block SQL injection"
          expression = "evaluatePreconfiguredExpr('sqli-stable')"
        },
        {
          action = "deny(403)"
          priority = 1001
          description = "Block XSS"
          expression = "evaluatePreconfiguredExpr('xss-stable')"
        },
        {
          action = "deny(403)"
          priority = 1002
          description = "Block remote file inclusion"
          expression = "evaluatePreconfiguredExpr('rfi-stable')"
        }
      ]
      adaptive_protection_config = {
        layer_7_ddos_defense_config = {
          enable = true
          rule_visibility = "STANDARD"
        }
      }
    }
  }
}

# Strict IAM Controls
module "iam_security" {
  source = "../../../modules/security/iam"

  project_id = var.project_id

  custom_roles = {
    "financial_auditor" = {
      title = "Financial Auditor"
      description = "Custom role for financial auditing"
      permissions = [
        "cloudasset.assets.searchAllResources",
        "logging.logEntries.list",
        "monitoring.alertPolicies.list"
      ]
    }
  }

  service_accounts = {
    "financial-sa" = {
      account_id = "financial-sa"
      display_name = "Financial Services SA"
      description = "Service account for financial services"
    }
  }

  bindings = {
    "roles/viewer" = {
      members = var.auditor_members
      condition = {
        title = "temporary_access"
        description = "Temporary access for audit"
        expression = "request.time < timestamp(\"2024-12-31T23:59:59Z\")"
      }
    }
  }
}

# Enhanced KMS Configuration
module "kms_security" {
  source = "../../../modules/security/kms"

  project_id = var.project_id
  location = var.region

  key_rings = {
    "financial-keyring" = {
      name = "financial-keyring"
      location = var.region
    }
  }

  crypto_keys = {
    "data-encryption-key" = {
      key_ring = "financial-keyring"
      rotation_period = "7776000s"  # 90 days
      purpose = "ENCRYPT_DECRYPT"
      version_template = {
        algorithm = "GOOGLE_SYMMETRIC_ENCRYPTION"
        protection_level = "HSM"
      }
    }
  }
}

# DLP for Financial Data
module "dlp_security" {
  source = "../../../modules/security/dlp"

  project_id = var.project_id

  inspect_templates = {
    "financial-template" = {
      display_name = "Financial Data Template"
      description = "Template for detecting financial data"
      inspect_config = {
        info_types = [
          "CREDIT_CARD_NUMBER",
          "BANK_ACCOUNT_NUMBER",
          "US_SOCIAL_SECURITY_NUMBER"
        ]
        min_likelihood = "VERY_LIKELY"
        limits = {
          max_findings_per_item = 100
          max_findings_per_request = 1000
        }
      }
    }
  }
}

# VPC Service Controls
module "vpc_sc" {
  source = "../../../modules/security/vpc_sc"

  organization_id = var.organization_id
  project_id = var.project_id

  access_policy = {
    title = "financial-policy"
    scopes = ["projects/${var.project_id}"]
  }

  service_perimeters = {
    "financial-perimeter" = {
      title = "financial_perimeter"
      description = "Perimeter for financial services"
      status = {
        restricted_services = [
          "storage.googleapis.com",
          "bigquery.googleapis.com",
          "cloudfunctions.googleapis.com"
        ]
        access_levels = ["accessPolicies/${var.access_policy_id}/accessLevels/trusted_access"]
        resources = ["projects/${var.project_id}"]
      }
    }
  }
}

# Enhanced Audit Logging
module "audit_logs" {
  source = "../../../modules/security/audit_logs"

  project_id = var.project_id

  audit_log_config = {
    service = "allServices"
    audit_log_configs = {
      log_type = "DATA_READ,DATA_WRITE,ADMIN_READ"
      exempted_members = []
    }
  }

  log_sinks = {
    "financial-audit-logs" = {
      destination = "storage.googleapis.com/${google_storage_bucket.audit_logs.name}"
      filter = "resource.type=gcs_bucket OR resource.type=bigquery_resource"
      unique_writer_identity = true
    }
  }
}

# Security Command Center
module "security_center" {
  source = "../../../modules/security/security_center"

  organization_id = var.organization_id
  project_id = var.project_id

  notification_configs = {
    "financial-alerts" = {
      description = "Financial security alerts"
      pubsub_topic = "projects/${var.project_id}/topics/financial-alerts"
      filter = "category = \"FINANCIAL_SECURITY\" OR severity = \"HIGH\""
    }
  }
}

# Compliance Controls
module "compliance" {
  source = "../../../modules/security/compliance"

  project_id = var.project_id
  organization_id = var.organization_id

  compliance_frameworks = {
    "pci-dss" = {
      enabled = true
      version = "3.2.1"
      controls = [
        "encryption",
        "access_control",
        "audit_logging",
        "network_security"
      ]
    }
    "sox" = {
      enabled = true
      version = "2002"
      controls = [
        "change_management",
        "access_control",
        "audit_logging"
      ]
    }
  }
}

# Essential Contacts
module "essential_contacts" {
  source = "../../../modules/security/essential_contacts"

  project_id = var.project_id
  organization_id = var.organization_id

  contacts = {
    "security-team" = {
      email = "security@example.com"
      notification_categories = ["SECURITY", "TECHNICAL"]
    }
    "compliance-team" = {
      email = "compliance@example.com"
      notification_categories = ["SECURITY", "LEGAL"]
    }
  }
}

# Security Response
module "security_response" {
  source = "../../../modules/security/response"

  project_id = var.project_id

  incident_configs = {
    "data-breach" = {
      display_name = "Data Breach Response"
      notification_channels = var.notification_channels
      alert_threshold = "HIGH"
    }
  }

  response_policies = {
    "financial-incident" = {
      name = "Financial Incident Response"
      description = "Response plan for financial security incidents"
      steps = [
        "Isolate affected systems",
        "Notify security team",
        "Begin forensic analysis",
        "Notify regulators if required"
      ]
    }
  }
}
