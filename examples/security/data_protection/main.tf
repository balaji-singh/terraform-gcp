/**
 * Data Protection Configuration
 * This example demonstrates comprehensive data security controls
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

# Cloud KMS for Data Encryption
module "data_encryption" {
  source = "../../../modules/security/kms"

  project_id = var.project_id
  location   = var.region

  key_rings = {
    "data-protection-keyring" = {
      name     = "data-protection-keyring"
      location = var.region
    }
  }

  crypto_keys = {
    "data-encryption-key" = {
      key_ring = "data-protection-keyring"
      rotation_period = "7776000s"  # 90 days
      purpose = "ENCRYPT_DECRYPT"
      version_template = {
        algorithm = "GOOGLE_SYMMETRIC_ENCRYPTION"
        protection_level = "HSM"
      }
    }
    "backup-encryption-key" = {
      key_ring = "data-protection-keyring"
      rotation_period = "7776000s"
      purpose = "ENCRYPT_DECRYPT"
      version_template = {
        algorithm = "GOOGLE_SYMMETRIC_ENCRYPTION"
        protection_level = "HSM"
      }
    }
  }
}

# DLP Configuration for Data Protection
module "dlp" {
  source = "../../../modules/security/dlp"

  project_id = var.project_id

  inspect_templates = {
    "sensitive-data-template" = {
      display_name = "Sensitive Data Template"
      description  = "Template for detecting sensitive data"
      inspect_config = {
        info_types = [
          "CREDIT_CARD_NUMBER",
          "EMAIL_ADDRESS",
          "PHONE_NUMBER",
          "US_SOCIAL_SECURITY_NUMBER"
        ]
        min_likelihood = "LIKELY"
        limits = {
          max_findings_per_item    = 100
          max_findings_per_request = 1000
        }
      }
    }
  }

  deidentify_templates = {
    "data-masking-template" = {
      display_name = "Data Masking Template"
      description  = "Template for masking sensitive data"
      deidentify_config = {
        info_type_transformations = {
          transformations = [
            {
              primitive_transformation = "MASK_CONFIG"
              masking_char = "*"
              number_to_mask = 4
            }
          ]
        }
      }
    }
  }
}

# VPC Service Controls for Data Access
module "data_vpc_sc" {
  source = "../../../modules/security/vpc_sc"

  organization_id = var.organization_id
  project_id     = var.project_id

  access_policy = {
    title = "data-protection-policy"
    scopes = ["projects/${var.project_id}"]
  }

  service_perimeters = {
    "data-protection-perimeter" = {
      title       = "data_protection_perimeter"
      description = "Perimeter for sensitive data protection"
      status = {
        restricted_services = [
          "storage.googleapis.com",
          "bigquery.googleapis.com",
          "dataflow.googleapis.com"
        ]
        access_levels = ["accessPolicies/${var.access_policy_id}/accessLevels/trusted_access"]
        resources    = ["projects/${var.project_id}"]
      }
    }
  }
}

# IAM for Data Access Control
module "data_access_iam" {
  source = "../../../modules/security/iam"

  project_id = var.project_id

  custom_roles = {
    "data_viewer" = {
      title       = "Data Viewer"
      description = "Role for viewing encrypted data"
      permissions = [
        "storage.objects.get",
        "storage.objects.list",
        "cloudkms.cryptoKeyVersions.useToDecrypt"
      ]
    }
  }

  bindings = {
    "roles/cloudkms.cryptoKeyDecrypter" = {
      members = var.data_access_members
      condition = {
        title       = "data_access_condition"
        description = "Condition for data access"
        expression  = "request.time < timestamp(\"2024-12-31T23:59:59Z\")"
      }
    }
  }
}

# Cloud Audit Logs for Data Access
module "data_audit" {
  source = "../../../modules/security/audit_logs"

  project_id = var.project_id

  audit_log_config = {
    service = "storage.googleapis.com"
    audit_log_configs = {
      log_type = "DATA_READ,DATA_WRITE"
      exempted_members = []
    }
  }

  log_sinks = {
    "data-access-logs" = {
      destination = "storage.googleapis.com/${google_storage_bucket.audit_logs.name}"
      filter      = "resource.type=gcs_bucket AND protoPayload.methodName=storage.objects.get"
      unique_writer_identity = true
    }
  }
}

# Security Command Center for Data Protection
module "data_security_center" {
  source = "../../../modules/security/security_center"

  organization_id = var.organization_id
  project_id     = var.project_id

  notification_configs = {
    "data-access-alerts" = {
      description  = "Data access alerts"
      pubsub_topic = "projects/${var.project_id}/topics/data-alerts"
      filter       = "category = \"DATA_LOSS\" OR category = \"UNAUTHORIZED_ACCESS\""
    }
  }

  security_findings = {
    "data-exposure" = {
      category    = "DATA_LOSS"
      severity    = "HIGH"
      source_id   = "data-protection"
      finding_class = "DATA_EXPOSURE"
    }
  }
}

# Asset Inventory for Data Resources
module "data_assets" {
  source = "../../../modules/security/asset_inventory"

  project_id = var.project_id

  feed_config = {
    asset_names = ["projects/${var.project_id}"]
    asset_types = [
      "storage.googleapis.com/Bucket",
      "bigquery.googleapis.com/Dataset",
      "cloudkms.googleapis.com/CryptoKey"
    ]
    content_type = "RESOURCE,IAM_POLICY"
    condition    = "state != DELETED"
  }
}
