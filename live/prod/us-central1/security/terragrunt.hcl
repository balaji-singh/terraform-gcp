include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules//security"
}

dependency "network" {
  config_path = "../network"
}

dependency "kms" {
  config_path = "../kms"
}

inputs = {
  # IAM Configuration
  iam_config = {
    custom_roles = {
      "security_auditor" = {
        title = "Security Auditor"
        permissions = [
          "cloudasset.assets.searchAllResources",
          "logging.logEntries.list",
          "monitoring.alertPolicies.list"
        ]
      }
    }
    service_accounts = {
      "security-sa" = {
        account_id = "security-sa"
        display_name = "Security Service Account"
      }
    }
  }

  # Security Command Center Configuration
  scc_config = {
    notification_configs = {
      "security-alerts" = {
        description = "High severity security alerts"
        pubsub_topic = "projects/${local.project_id}/topics/security-alerts"
        filter = "severity = HIGH OR severity = CRITICAL"
      }
    }
  }

  # Cloud Armor Configuration
  cloud_armor_config = {
    security_policies = {
      "waf-policy" = {
        description = "WAF security policy"
        rules = [
          {
            action = "deny(403)"
            priority = 1000
            description = "Block SQL injection"
            expression = "evaluatePreconfiguredExpr('sqli-stable')"
          }
        ]
      }
    }
  }

  # VPC Service Controls
  vpc_sc_config = {
    access_policy = {
      title = "prod-policy"
      scopes = ["projects/${local.project_id}"]
    }
    service_perimeters = {
      "prod-perimeter" = {
        title = "Production Perimeter"
        restricted_services = [
          "storage.googleapis.com",
          "bigquery.googleapis.com"
        ]
      }
    }
  }

  # Binary Authorization
  binary_auth_config = {
    policy_config = {
      global_policy_evaluation_mode = "ENABLE"
      default_admission_rule = {
        evaluation_mode = "REQUIRE_ATTESTATION"
        enforcement_mode = "ENFORCED_BLOCK_AND_AUDIT_LOG"
      }
    }
  }

  # Secret Manager
  secret_manager_config = {
    secrets = {
      "prod-secrets" = {
        replication = {
          automatic = true
        }
        rotation = {
          rotation_period = "7776000s"
        }
      }
    }
  }

  # DLP Configuration
  dlp_config = {
    inspect_templates = {
      "sensitive-data" = {
        display_name = "Sensitive Data Template"
        inspect_config = {
          info_types = [
            "CREDIT_CARD_NUMBER",
            "EMAIL_ADDRESS",
            "PHONE_NUMBER"
          ]
        }
      }
    }
  }

  # Audit Logging
  audit_config = {
    audit_log_config = {
      service = "allServices"
      audit_log_configs = {
        log_type = "DATA_READ,DATA_WRITE,ADMIN_READ"
      }
    }
  }

  # Security Monitoring
  monitoring_config = {
    alert_policies = {
      "security-alerts" = {
        display_name = "Critical Security Alerts"
        conditions = [
          {
            display_name = "High Severity Finding"
            condition_threshold = {
              filter = "resource.type=organization metric.type=securitycenter.googleapis.com/finding_count"
              comparison = "COMPARISON_GT"
              threshold_value = 0
            }
          }
        ]
      }
    }
  }
}
