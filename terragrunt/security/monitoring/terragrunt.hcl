include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/security/monitoring"
}

inputs = {
  alert_policies = {
    "security-alerts" = {
      display_name = "Security Alerts"
      combiner = "OR"
      conditions = [
        {
          display_name = "High Severity Security Finding"
          condition_threshold = {
            filter = "metric.type=\"securitycenter.googleapis.com/finding_count\" resource.type=\"organization\" metric.label.severity=\"HIGH\""
            duration = "300s"
            comparison = "COMPARISON_GT"
            threshold_value = 0
          }
        }
      ]
    }
  }

  notification_channels = [
    "projects/${local.project_id}/notificationChannels/email-security-team",
    "projects/${local.project_id}/notificationChannels/slack-security"
  ]
}
