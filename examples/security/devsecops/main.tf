/**
 * DevSecOps Pipeline Security Configuration
 * This example demonstrates security configurations for CI/CD pipelines
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

# Cloud Build with Security Controls
module "secure_build" {
  source = "../../../modules/security/cloud_build"

  project_id = var.project_id

  triggers = {
    "secure-build" = {
      name = "secure-build"
      trigger_template {
        branch_name = "main"
        repo_name   = "my-secure-repo"
      }
      build {
        steps = [
          {
            name = "gcr.io/cloud-builders/docker"
            args = ["build", "-t", "gcr.io/$PROJECT_ID/secure-app", "."]
          },
          {
            name = "gcr.io/$PROJECT_ID/security-scanner"
            args = ["scan", "gcr.io/$PROJECT_ID/secure-app"]
          },
          {
            name = "gcr.io/cloud-builders/gke-deploy"
            args = ["run", "--filename=k8s/", "--cluster=secure-cluster"]
          }
        ]
      }
    }
  }
}

# Binary Authorization for Build Pipeline
module "binary_auth" {
  source = "../../../modules/security/binary_authorization"

  project_id = var.project_id

  policy_config = {
    global_policy_evaluation_mode = "ENABLE"
    default_admission_rule = {
      evaluation_mode  = "REQUIRE_ATTESTATION"
      enforcement_mode = "ENFORCED_BLOCK_AND_AUDIT_LOG"
      attestation_patterns = {
        google_binary_authorization_attestor = {
          name = "security-attestor"
          note_reference = "projects/${var.project_id}/notes/security-note"
        }
      }
    }
  }
}

# Container Analysis for Image Scanning
module "container_analysis" {
  source = "../../../modules/security/container_analysis"

  project_id = var.project_id

  notes = {
    "security-note" = {
      short_description = "Security scan results"
      long_description = "Results of vulnerability scanning and policy compliance"
      attestation_authority = {
        hint = {
          human_readable_name = "Security Team Attestation"
        }
      }
    }
  }

  occurrences = {
    "vulnerability-scan" = {
      note_name    = "projects/${var.project_id}/notes/security-note"
      resource_uri = "gcr.io/${var.project_id}/secure-app"
      vulnerability = {
        severity = "HIGH"
        details  = "Critical vulnerability found"
      }
    }
  }
}

# Secret Manager for Pipeline Secrets
module "pipeline_secrets" {
  source = "../../../modules/security/secrets"

  project_id = var.project_id

  secrets = {
    "pipeline-key" = {
      secret_id = "pipeline-key"
      replication = {
        automatic = true
      }
      rotation = {
        next_rotation_time = timeadd(timestamp(), "720h")
        rotation_period   = "720h"
      }
    }
  }
}

# IAM for Pipeline Service Accounts
module "pipeline_iam" {
  source = "../../../modules/security/iam"

  project_id = var.project_id

  service_accounts = {
    "pipeline-sa" = {
      account_id   = "pipeline-sa"
      display_name = "Pipeline Service Account"
      description  = "Service account for CI/CD pipeline"
    }
  }

  bindings = {
    "roles/cloudbuild.builds.builder" = {
      members = [
        "serviceAccount:${module.pipeline_iam.service_accounts["pipeline-sa"].email}"
      ]
    }
  }
}

# Security Scanner for Pipeline Artifacts
module "artifact_scanner" {
  source = "../../../modules/security/security_scanner"

  project_id = var.project_id

  scan_configs = {
    "artifact-scan" = {
      starting_urls    = ["https://gcr.io/${var.project_id}/secure-app"]
      target_platforms = ["COMPUTE"]
      schedule_interval = "EVERY_DAY"
      export_to_security_command_center = {
        enable = true
        filter = ""
      }
    }
  }
}

# Audit Logging for Pipeline Activities
module "pipeline_audit" {
  source = "../../../modules/security/audit_logs"

  project_id = var.project_id

  audit_log_config = {
    service = "cloudbuild.googleapis.com"
    audit_log_configs = {
      log_type = "DATA_WRITE"
      exempted_members = []
    }
  }
}

# Security Command Center Integration
module "pipeline_security_center" {
  source = "../../../modules/security/security_center"

  organization_id = var.organization_id
  project_id     = var.project_id

  notification_configs = {
    "pipeline-alerts" = {
      description  = "Pipeline security alerts"
      pubsub_topic = "projects/${var.project_id}/topics/pipeline-alerts"
      filter       = "category = \"CONTAINER_VULNERABILITY\" OR category = \"BUILD_FAILURE\""
    }
  }
}

# KMS for Pipeline Artifacts
module "pipeline_kms" {
  source = "../../../modules/security/kms"

  project_id = var.project_id
  location   = var.region

  key_rings = {
    "pipeline-keyring" = {
      name     = "pipeline-keyring"
      location = var.region
    }
  }

  crypto_keys = {
    "artifact-signing-key" = {
      key_ring = "pipeline-keyring"
      rotation_period = "7776000s"  # 90 days
      purpose = "ASYMMETRIC_SIGN"
      version_template = {
        algorithm = "RSA_SIGN_PKCS1_4096_SHA512"
        protection_level = "SOFTWARE"
      }
    }
  }
}
