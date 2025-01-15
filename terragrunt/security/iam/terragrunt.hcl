include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/security/iam"
}

inputs = {
  custom_roles = {
    "security_auditor" = {
      title = "Security Auditor"
      description = "Custom role for security auditing"
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
      description = "Service account for security operations"
    }
  }

  bindings = {
    "roles/viewer" = {
      members = ["group:security-team@example.com"]
      condition = {
        title = "temporary_access"
        description = "Temporary access for audit"
        expression = "request.time < timestamp(\"2024-12-31T23:59:59Z\")"
      }
    }
  }
}
