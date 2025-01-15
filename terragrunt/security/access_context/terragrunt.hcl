include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/security/access_context"
}

dependency "vpc_sc" {
  config_path = "../vpc_sc"
}

inputs = {
  access_levels = {
    "trusted-access" = {
      name = "trusted_access"
      title = "Trusted Access Level"
      basic = {
        conditions = [
          {
            ip_subnetworks = ["10.0.0.0/8"]
            required_access_levels = []
            members = [
              "user:admin@example.com",
              "serviceAccount:service@example.com"
            ]
            negate = false
            device_policy = {
              require_screen_lock = true
              os_constraints = [
                {
                  os_type = "DESKTOP_MAC"
                  minimum_version = "10.15.7"
                }
              ]
            }
          }
        ]
      }
    }
    "mfa-access" = {
      name = "mfa_access"
      title = "MFA Required Access"
      basic = {
        conditions = [
          {
            ip_subnetworks = ["10.0.0.0/8"]
            required_access_levels = ["trusted_access"]
            members = []
            negate = false
            device_policy = {
              require_screen_lock = true
              require_admin_approval = true
              require_corp_owned = true
            }
          }
        ]
      }
    }
  }

  access_policies = {
    "security-policy" = {
      parent = "organizations/${local.organization_id}"
      title = "Security Access Policy"
      scopes = ["projects/${local.project_id}"]
    }
  }

  service_perimeters = {
    "secure-perimeter" = {
      title = "Secure Service Perimeter"
      status = {
        restricted_services = [
          "storage.googleapis.com",
          "bigquery.googleapis.com"
        ]
        access_levels = ["trusted_access", "mfa_access"]
        resources = ["projects/${local.project_id}"]
        vpc_accessible_services = {
          enable_restriction = true
          allowed_services = ["compute.googleapis.com"]
        }
      }
      spec = {
        resources = ["projects/${local.project_id}"]
        access_levels = ["trusted_access", "mfa_access"]
        restricted_services = [
          "storage.googleapis.com",
          "bigquery.googleapis.com"
        ]
        vpc_accessible_services = {
          enable_restriction = true
          allowed_services = ["compute.googleapis.com"]
        }
      }
    }
  }

  bridge_config = {
    "secure-bridge" = {
      status = {
        resources = ["projects/${local.project_id}"]
        access_levels = ["trusted_access"]
        restricted_services = ["bigquery.googleapis.com"]
      }
    }
  }

  monitoring_config = {
    metrics = {
      "access_requests" = {
        type = "custom.googleapis.com/access_context/requests"
        description = "Access context manager requests"
      }
    }
    alerts = {
      "unauthorized_access" = {
        condition = "resource.type=access_context_manager AND severity=ERROR"
        notification_channels = ["email", "slack"]
      }
    }
  }

  audit_config = {
    "access-audit" = {
      log_type = "data_access"
      filter = "resource.type=access_context_manager"
      destination = "logging.googleapis.com"
    }
  }

  compliance_config = {
    "access-compliance" = {
      standards = ["SOC2", "HIPAA"]
      checks = [
        "access_level_configuration",
        "perimeter_configuration"
      ]
      reporting = {
        enabled = true
        frequency = "daily"
        recipients = ["compliance@example.com"]
      }
    }
  }
}
