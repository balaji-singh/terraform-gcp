include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/security/health_analytics"
}

dependency "security_center" {
  config_path = "../security_center"
}

inputs = {
  custom_modules = {
    "compliance-check" = {
      display_name = "Compliance Check Module"
      description = "Custom module for compliance verification"
      enablement_state = "ENABLED"
      severity = "HIGH"
      module_type = "COMPLIANCE"
      custom_config = {
        resource_types = ["google_project", "google_storage_bucket"]
        evaluation_frequency = "DAILY"
      }
    }
    "security-posture" = {
      display_name = "Security Posture Assessment"
      description = "Module for security posture analysis"
      enablement_state = "ENABLED"
      severity = "CRITICAL"
      module_type = "SECURITY_HEALTH"
      custom_config = {
        resource_types = ["google_compute_instance", "google_container_cluster"]
        evaluation_frequency = "HOURLY"
      }
    }
  }

  health_rules = {
    "encryption-check" = {
      name = "Encryption Configuration Check"
      description = "Verify encryption settings across resources"
      resource_types = ["google_storage_bucket", "google_sql_database_instance"]
      conditions = {
        encryption = "customer_managed_key"
        key_rotation = "enabled"
      }
    }
    "iam-check" = {
      name = "IAM Policy Check"
      description = "Check IAM policies for security best practices"
      resource_types = ["google_project_iam_policy", "google_storage_bucket_iam_policy"]
      conditions = {
        public_access = "denied"
        service_account_keys = "rotated"
      }
    }
  }

  monitoring_config = {
    metrics = {
      "compliance-score" = {
        type = "custom.googleapis.com/security/compliance_score"
        description = "Overall compliance score"
        metric_kind = "GAUGE"
        value_type = "DOUBLE"
      }
      "security-findings" = {
        type = "custom.googleapis.com/security/finding_count"
        description = "Number of security findings"
        metric_kind = "GAUGE"
        value_type = "INT64"
      }
    }
    dashboards = {
      "security-health" = {
        display_name = "Security Health Dashboard"
        grid_layout = true
        widgets = [
          {
            title = "Compliance Score Trend"
            type = "LINE"
            metric = "custom.googleapis.com/security/compliance_score"
            timeframe = "1d"
          },
          {
            title = "Security Findings by Severity"
            type = "PIE"
            metric = "custom.googleapis.com/security/finding_count"
            group_by = ["severity"]
          }
        ]
      }
    }
  }

  remediation_config = {
    "auto-remediation" = {
      enabled = true
      actions = {
        "fix-public-access" = {
          trigger = "public_access_detected"
          action = "remove_public_access"
          approval_required = true
        }
        "rotate-keys" = {
          trigger = "key_rotation_needed"
          action = "rotate_service_account_keys"
          approval_required = false
        }
      }
    }
  }
}
