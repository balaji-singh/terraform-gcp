/**
 * Healthcare Security Composition
 * This composition implements security controls for healthcare compliance (HIPAA)
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

# Network Security for Healthcare
module "network_security" {
  source = "../../../modules/security/network"

  project_id = var.project_id
  network_name = var.network_name

  subnets = {
    "phi-subnet" = {
      name = "phi-subnet"
      ip_cidr_range = "10.0.1.0/24"
      region = var.region
      private_ip_google_access = true
      secondary_ranges = {}
    }
  }

  firewall_rules = {
    "allow-internal-phi" = {
      name = "allow-internal-phi"
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

# Healthcare API Security
module "healthcare_api" {
  source = "../../../modules/security/healthcare"

  project_id = var.project_id

  datasets = {
    "phi-dataset" = {
      name = "phi-dataset"
      location = var.region
      time_zone = "UTC"
    }
  }

  dicom_stores = {
    "secure-dicom" = {
      dataset = "phi-dataset"
      name = "secure-dicom"
      notification_config = {
        pubsub_topic = "projects/${var.project_id}/topics/dicom-notifications"
      }
    }
  }

  fhir_stores = {
    "secure-fhir" = {
      dataset = "phi-dataset"
      name = "secure-fhir"
      version = "R4"
      enable_update_create = false
      notification_config = {
        pubsub_topic = "projects/${var.project_id}/topics/fhir-notifications"
      }
    }
  }
}

# Enhanced DLP for PHI
module "dlp_security" {
  source = "../../../modules/security/dlp"

  project_id = var.project_id

  inspect_templates = {
    "phi-template" = {
      display_name = "PHI Data Template"
      description = "Template for detecting PHI"
      inspect_config = {
        info_types = [
          "US_SOCIAL_SECURITY_NUMBER",
          "PERSON_NAME",
          "DATE_OF_BIRTH",
          "MEDICAL_RECORD_NUMBER",
          "US_HEALTHCARE_NPI"
        ]
        min_likelihood = "VERY_LIKELY"
        limits = {
          max_findings_per_item = 100
          max_findings_per_request = 1000
        }
      }
    }
  }

  deidentify_templates = {
    "phi-deidentify" = {
      display_name = "PHI De-identification Template"
      description = "Template for de-identifying PHI"
      deidentify_config = {
        info_type_transformations = {
          transformations = [
            {
              primitive_transformation = "CRYPTO_DETERMINISTIC_CONFIG"
            }
          ]
        }
      }
    }
  }
}

# KMS for PHI Encryption
module "kms_security" {
  source = "../../../modules/security/kms"

  project_id = var.project_id
  location = var.region

  key_rings = {
    "phi-keyring" = {
      name = "phi-keyring"
      location = var.region
    }
  }

  crypto_keys = {
    "phi-encryption-key" = {
      key_ring = "phi-keyring"
      rotation_period = "7776000s"  # 90 days
      purpose = "ENCRYPT_DECRYPT"
      version_template = {
        algorithm = "GOOGLE_SYMMETRIC_ENCRYPTION"
        protection_level = "HSM"
      }
    }
  }
}

# VPC Service Controls for PHI
module "vpc_sc" {
  source = "../../../modules/security/vpc_sc"

  organization_id = var.organization_id
  project_id = var.project_id

  access_policy = {
    title = "phi-policy"
    scopes = ["projects/${var.project_id}"]
  }

  service_perimeters = {
    "phi-perimeter" = {
      title = "phi_perimeter"
      description = "Perimeter for PHI data"
      status = {
        restricted_services = [
          "healthcare.googleapis.com",
          "storage.googleapis.com",
          "bigquery.googleapis.com"
        ]
        access_levels = ["accessPolicies/${var.access_policy_id}/accessLevels/trusted_access"]
        resources = ["projects/${var.project_id}"]
      }
    }
  }
}

# IAM for Healthcare Access
module "iam_security" {
  source = "../../../modules/security/iam"

  project_id = var.project_id

  custom_roles = {
    "phi_auditor" = {
      title = "PHI Auditor"
      description = "Custom role for PHI auditing"
      permissions = [
        "healthcare.datasets.get",
        "healthcare.datasets.list",
        "logging.logEntries.list"
      ]
    }
  }

  service_accounts = {
    "healthcare-sa" = {
      account_id = "healthcare-sa"
      display_name = "Healthcare Service Account"
      description = "Service account for healthcare operations"
    }
  }

  bindings = {
    "roles/healthcare.datasetViewer" = {
      members = var.healthcare_members
      condition = {
        title = "phi_access"
        description = "Access to PHI data"
        expression = "request.time < timestamp(\"2024-12-31T23:59:59Z\")"
      }
    }
  }
}

# Enhanced Audit Logging for PHI
module "audit_logs" {
  source = "../../../modules/security/audit_logs"

  project_id = var.project_id

  audit_log_config = {
    service = "healthcare.googleapis.com"
    audit_log_configs = {
      log_type = "DATA_READ,DATA_WRITE,ADMIN_READ"
      exempted_members = []
    }
  }

  log_sinks = {
    "phi-audit-logs" = {
      destination = "storage.googleapis.com/${google_storage_bucket.audit_logs.name}"
      filter = "resource.type=healthcare.googleapis.com"
      unique_writer_identity = true
    }
  }
}

# Security Command Center for Healthcare
module "security_center" {
  source = "../../../modules/security/security_center"

  organization_id = var.organization_id
  project_id = var.project_id

  notification_configs = {
    "phi-alerts" = {
      description = "PHI security alerts"
      pubsub_topic = "projects/${var.project_id}/topics/phi-alerts"
      filter = "category = \"PHI_ACCESS\" OR severity = \"HIGH\""
    }
  }
}

# Compliance Controls for HIPAA
module "compliance" {
  source = "../../../modules/security/compliance"

  project_id = var.project_id
  organization_id = var.organization_id

  compliance_frameworks = {
    "hipaa" = {
      enabled = true
      version = "2013"
      controls = [
        "access_control",
        "audit_logging",
        "encryption",
        "integrity_monitoring",
        "business_continuity"
      ]
    }
  }
}

# Essential Contacts for Healthcare
module "essential_contacts" {
  source = "../../../modules/security/essential_contacts"

  project_id = var.project_id
  organization_id = var.organization_id

  contacts = {
    "privacy-officer" = {
      email = "privacy@example.com"
      notification_categories = ["SECURITY", "TECHNICAL", "LEGAL"]
    }
    "security-team" = {
      email = "security@example.com"
      notification_categories = ["SECURITY", "TECHNICAL"]
    }
  }
}

# Security Response for Healthcare
module "security_response" {
  source = "../../../modules/security/response"

  project_id = var.project_id

  incident_configs = {
    "phi-breach" = {
      display_name = "PHI Data Breach Response"
      notification_channels = var.notification_channels
      alert_threshold = "HIGH"
    }
  }

  response_policies = {
    "hipaa-incident" = {
      name = "HIPAA Incident Response"
      description = "Response plan for HIPAA security incidents"
      steps = [
        "Isolate affected systems",
        "Notify privacy officer",
        "Begin breach assessment",
        "Implement mitigation measures",
        "Notify affected individuals if required",
        "Report to HHS if required"
      ]
    }
  }
}

# Backup and Recovery for PHI
module "backup_recovery" {
  source = "../../../modules/security/backup"

  project_id = var.project_id

  backup_configs = {
    "phi-backup" = {
      name = "phi-backup"
      location = var.region
      retention_days = 365
      encryption_key = module.kms_security.crypto_keys["phi-encryption-key"].id
    }
  }
}
