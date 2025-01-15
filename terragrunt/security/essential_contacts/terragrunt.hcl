include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/security/essential_contacts"
}

inputs = {
  contacts = {
    "security-team" = {
      email = "security@example.com"
      notification_categories = ["SECURITY", "TECHNICAL"]
    }
    "compliance-team" = {
      email = "compliance@example.com"
      notification_categories = ["SECURITY", "LEGAL"]
    }
    "incident-response" = {
      email = "ir@example.com"
      notification_categories = ["SECURITY", "TECHNICAL"]
    }
  }
}
