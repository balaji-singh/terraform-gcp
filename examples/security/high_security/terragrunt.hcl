include {
  path = find_in_parent_folders()
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "../../..//modules/security"

  extra_arguments "custom_vars" {
    commands = [
      "apply",
      "plan",
      "import",
      "push",
      "refresh"
    ]
  }

  before_hook "verify_security_requirements" {
    commands = ["apply"]
    execute  = [
      "../../scripts/validate_security.sh",
      "-p", "${local.env_vars.locals.project_id}",
      "-e", "${local.env_vars.locals.environment}"
    ]
  }
}

inputs = merge(
  local.env_vars.locals,
  {
    # VPC Service Controls Configuration
    vpc_sc_config = {
      access_policy = {
        title = "high-security-policy"
        scopes = ["projects/${local.env_vars.locals.project_id}"]
      }
      service_perimeters = {
        "high-security-perimeter" = {
          title = "high_security_perimeter"
          restricted_services = [
            "storage.googleapis.com",
            "bigquery.googleapis.com",
            "cloudfunctions.googleapis.com",
            "cloudkms.googleapis.com"
          ]
        }
      }
    }

    # Binary Authorization Configuration
    binary_auth_config = {
      default_admission_rule = {
        evaluation_mode  = "REQUIRE_ATTESTATION"
        enforcement_mode = "ENFORCED_BLOCK_AND_AUDIT_LOG"
      }
      cluster_admission_rules = {
        "us-central1" = {
          evaluation_mode  = "REQUIRE_ATTESTATION"
          enforcement_mode = "ENFORCED_BLOCK_AND_AUDIT_LOG"
        }
      }
    }

    # Audit Logging Configuration
    audit_config = {
      services = ["allServices"]
      audit_log_configs = {
        log_type = "ADMIN_READ,DATA_READ,DATA_WRITE"
      }
      retention_days = 365
    }

    # Security Command Center Configuration
    scc_config = {
      notification_config = {
        description = "Critical security alerts"
        pubsub_topic = "projects/${local.env_vars.locals.project_id}/topics/security-alerts"
      }
      custom_modules = {
        "threat-detection" = {
          finding_class_name = "BRUTE_FORCE"
          severity = "CRITICAL"
        }
      }
    }

    # IAM Configuration
    iam_config = {
      custom_roles = {
        "restricted_viewer" = {
          title = "Restricted Viewer"
          permissions = [
            "compute.instances.get",
            "compute.instances.list"
          ]
        }
      }
      bindings = {
        "roles/viewer" = {
          condition = {
            title = "ip_restricted"
            expression = "request.origin.ip.inIpRange('10.0.0.0/8')"
          }
        }
      }
    }

    # KMS Configuration
    kms_config = {
      key_rings = {
        "high-security-keyring" = {
          location = local.env_vars.locals.region
        }
      }
      crypto_keys = {
        "data-encryption-key" = {
          rotation_period = "7776000s"
          protection_level = "HSM"
        }
      }
    }

    # Security Scanner Configuration
    scanner_config = {
      scan_schedule = "EVERY_DAY"
      export_to_security_center = true
      max_qps = 10
    }

    # Asset Inventory Configuration
    asset_inventory_config = {
      asset_types = [
        "compute.googleapis.com/Instance",
        "storage.googleapis.com/Bucket",
        "iam.googleapis.com/ServiceAccount"
      ]
      content_type = "RESOURCE,IAM_POLICY,ORG_POLICY"
      feed_output_config = {
        pubsub = {
          topic = "projects/${local.env_vars.locals.project_id}/topics/asset-changes"
        }
      }
    }

    # Additional Security Settings
    security_settings = {
      enable_os_login = true
      enable_shielded_vm = true
      block_project_ssh_keys = true
      enable_vpc_service_controls = true
      enable_cloud_audit_logs = true
    }

    # Compliance Requirements
    compliance_requirements = {
      hipaa = true
      pci = true
      sox = true
      iso_27001 = true
    }
  }
)
