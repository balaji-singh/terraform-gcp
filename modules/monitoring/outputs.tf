output "dashboards" {
  description = "Map of created monitoring dashboards"
  value = {
    for k, v in google_monitoring_dashboard.dashboard : k => {
      name       = v.dashboard_json
      project_id = v.project
    }
  }
}

output "alert_policies" {
  description = "Map of created alert policies"
  value = {
    for k, v in google_monitoring_alert_policy.alert_policy : k => {
      name            = v.name
      display_name    = v.display_name
      enabled         = v.enabled
      project_id      = v.project
      conditions      = v.conditions
      documentation   = v.documentation
      notification_channels = v.notification_channels
    }
  }
}

output "notification_channels" {
  description = "Map of created notification channels"
  value = {
    for k, v in google_monitoring_notification_channel.notification_channel : k => {
      name         = v.name
      display_name = v.display_name
      type         = v.type
      project_id   = v.project
      enabled      = v.enabled
      labels       = v.labels
      verification_status = v.verification_status
    }
  }
  sensitive = true
}

output "uptime_checks" {
  description = "Map of created uptime checks"
  value = {
    for k, v in google_monitoring_uptime_check_config.uptime_check : k => {
      name         = v.name
      display_name = v.display_name
      project_id   = v.project
      timeout      = v.timeout
      period       = v.period
      selected_regions = v.selected_regions
    }
  }
}
