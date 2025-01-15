/**
 * High Security Environment Configuration
 * This example demonstrates a configuration suitable for highly regulated industries
 * like finance, healthcare, or government sectors.
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

# VPC Service Controls
module "vpc_sc" {
  source = "../../../modules/security/vpc_sc"

  organization_id = var.organization_id
  project_id     = var.project_id

  access_policy = {
    title = "high-security-policy"
    scopes = ["projects/${var.project_id}"]
  }

  service_perimeters = {
    "high-security-perimeter" = {
      title       = "high_security_perimeter"
      description = "Perimeter for high security workloads"
      status = {
        restricted_services = [
          "storage.googleapis.com",
          "bigquery.googleapis.com",
          "cloudfunctions.googleapis.com",
          "cloudkms.googleapis.com"
        ]
        access_levels = ["accessPolicies/${var.access_policy_id}/accessLevels/trusted_access"]
        resources    = ["projects/${var.project_id}"]
      }
    }
  }
}

# Binary Authorization with Strict Rules
module "binary_auth" {
  source = "../../../modules/security/binary_authorization"

  project_id = var.project_id

  policy_config = {
    global_policy_evaluation_mode = "ENABLE"
    default_admission_rule = {
      evaluation_mode  = "REQUIRE_ATTESTATION"
      enforcement_mode = "ENFORCED_BLOCK_AND_AUDIT_LOG"
      requirements = {
        attestations = [{
          attestation_authority_note = "projects/${var.project_id}/notes/security-attestation"
          attestation_authority_note_version = "latest"
        }]
      }
    }
  }

  cluster_admission_rules = {
    "us-central1" = {
      cluster               = "*"
      evaluation_mode       = "REQUIRE_ATTESTATION"
      enforcement_mode      = "ENFORCED_BLOCK_AND_AUDIT_LOG"
      require_attestations  = true
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
      log_type = "ADMIN_READ,DATA_READ,DATA_WRITE"
      exempted_members = []
    }
  }

  log_sinks = {
    "all-audit-logs" = {
      destination = "storage.googleapis.com/${google_storage_bucket.audit_logs.name}"
      filter      = "protoPayload.@type=\"type.googleapis.com/google.cloud.audit.AuditLog\""
      unique_writer_identity = true
    }
  }
}

# Security Command Center with Advanced Threat Detection
module "security_center" {
  source = "../../../modules/security/security_center"

  organization_id = var.organization_id
  project_id     = var.project_id

  notification_configs = {
    "critical-alerts" = {
      description  = "Critical security alerts"
      pubsub_topic = "projects/${var.project_id}/topics/security-alerts"
      filter       = "severity = CRITICAL"
    }
  }

  security_sources = {
    "custom-threat-detection" = {
      display_name = "Custom Threat Detection"
      description  = "Custom threat detection rules"
      finding_configs = [{
        finding_class_name = "BRUTE_FORCE"
        severity          = "CRITICAL"
        indicator = {
          resource_type = "compute.googleapis.com/Instance"
          category      = "COMPROMISED_CREDENTIAL"
        }
      }]
    }
  }
}

# IAM with Strict Policies
module "strict_iam" {
  source = "../../../modules/security/iam"

  project_id = var.project_id

  custom_roles = {
    "restricted_viewer" = {
      title       = "Restricted Viewer"
      description = "Limited read-only access with additional restrictions"
      permissions = [
        "compute.instances.get",
        "compute.instances.list",
        "storage.objects.get",
        "storage.objects.list"
      ]
    }
  }

  service_accounts = {
    "restricted-sa" = {
      account_id   = "restricted-sa"
      display_name = "Restricted Service Account"
      description  = "Service account with minimal permissions"
    }
  }

  bindings = {
    "roles/viewer" = {
      members = [
        "serviceAccount:${module.strict_iam.service_accounts["restricted-sa"].email}"
      ]
      condition = {
        title       = "ip_restricted"
        description = "Only allow access from trusted IPs"
        expression  = "request.origin.ip.inIpRange('10.0.0.0/8')"
      }
    }
  }
}

# KMS with Customer Managed Keys
module "kms" {
  source = "../../../modules/security/kms"

  project_id = var.project_id
  location   = var.region

  key_rings = {
    "high-security-keyring" = {
      name     = "high-security-keyring"
      location = var.region
    }
  }

  crypto_keys = {
    "data-encryption-key" = {
      key_ring = "high-security-keyring"
      rotation_period = "7776000s"  # 90 days
      purpose = "ENCRYPT_DECRYPT"
      version_template = {
        algorithm = "GOOGLE_SYMMETRIC_ENCRYPTION"
        protection_level = "HSM"
      }
    }
  }
}

# Security Scanner with Enhanced Scanning
module "security_scanner" {
  source = "../../../modules/security/security_scanner"

  project_id = var.project_id

  scan_configs = {
    "enhanced-security-scan" = {
      starting_urls    = var.scan_urls
      target_platforms = ["COMPUTE"]
      schedule_interval = "EVERY_DAY"
      max_qps = 10
      export_to_security_command_center = {
        enable = true
        filter = ""
      }
      authentication = {
        google_account = {
          username = var.scanner_username
          password = var.scanner_password
        }
      }
    }
  }
}

# Asset Inventory with Detailed Tracking
module "asset_inventory" {
  source = "../../../modules/security/asset_inventory"

  project_id = var.project_id

  feed_config = {
    asset_names = ["projects/${var.project_id}"]
    asset_types = [
      "compute.googleapis.com/Instance",
      "storage.googleapis.com/Bucket",
      "iam.googleapis.com/ServiceAccount",
      "container.googleapis.com/Cluster"
    ]
    content_type = "RESOURCE,IAM_POLICY,ORG_POLICY,ACCESS_POLICY"
    condition    = "state != DELETED"
  }
}
