provider "google" {
  project = var.project_id
  region  = var.region
}

module "access_context" {
  source = "../../../modules/security/access_context"

  organization_id = var.organization_id
  create_access_policy = true
  policy_title = "Corporate Access Policy"
  policy_scopes = ["projects/${var.project_id}"]

  # Custom Access Levels
  custom_access_levels = {
    "corporate_devices" = {
      title = "Corporate Devices"
      basic = {
        conditions = [{
          os_constraints = [
            {
              os_type = "DESKTOP_CHROME_OS"
              minimum_version = "86.0.0"
              require_verified_chrome_os = true
            },
            {
              os_type = "DESKTOP_MAC"
              minimum_version = "10.15.0"
            }
          ]
          require_screen_lock = true
          allowed_encryption_statuses = ["ENCRYPTED"]
          allowed_device_management_levels = ["COMPANY_OWNED"]
          require_admin_approval = true
          require_corp_owned = true
          ip_subnetworks = ["10.0.0.0/8"]
          members = ["group:employees@example.com"]
          regions = ["US", "CA"]
          negate = false
        }]
        combining_function = "AND"
      }
    },
    "custom_rule" = {
      title = "Custom Security Rule"
      custom = {
        expression = "expression.custom_rule"
        title     = "Custom Rule Expression"
        location  = "global"
      }
    }
  }

  # GCP User Access Bindings
  gcp_user_access_bindings = {
    "dev_team" = {
      group_key = "security_group_1"
      access_levels = ["corporate_devices"]
    }
  }

  # Service Perimeter Bridges
  service_perimeter_bridges = {
    "project_bridge" = {
      perimeter_name = "accessPolicies/${var.existing_policy_id}/servicePerimeters/bridge"
      resource      = "projects/${var.project_id}"
    }
  }

  # Access Policy IAM
  access_policy_iam_bindings = {
    "policy_admin" = {
      role    = "roles/accesscontextmanager.policyAdmin"
      members = ["group:security-admins@example.com"]
      condition = {
        title       = "temporary_access"
        description = "Temporary admin access"
        expression  = "request.time < timestamp('2024-12-31T23:59:59Z')"
      }
    },
    "policy_reader" = {
      role    = "roles/accesscontextmanager.policyReader"
      members = ["group:security-auditors@example.com"]
    }
  }
}
