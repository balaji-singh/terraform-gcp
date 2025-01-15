include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/security/security_center"
}

inputs = {
  notification_configs = {
    "security-alerts" = {
      description = "Security alerts"
      pubsub_topic = "projects/${local.project_id}/topics/security-alerts"
      filter = "category = \"THREAT_DETECTION\" OR severity = \"HIGH\""
    }
  }

  security_findings = {
    "security-finding" = {
      category = "THREAT_DETECTION"
      severity = "HIGH"
      source_id = "security-scanner"
      finding_class = "VULNERABILITY"
    }
  }
}
