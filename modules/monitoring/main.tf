/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 */

resource "google_monitoring_dashboard" "dashboard" {
  for_each = var.dashboards

  dashboard_json = jsonencode({
    displayName = each.value.display_name
    gridLayout = {
      columns = each.value.grid_layout.columns
      widgets = each.value.grid_layout.widgets
    }
  })
  project = var.project_id
}

resource "google_monitoring_alert_policy" "alert_policy" {
  for_each = var.alert_policies

  display_name = each.value.display_name
  project      = var.project_id
  enabled      = each.value.enabled

  documentation {
    content   = each.value.documentation.content
    mime_type = each.value.documentation.mime_type
  }

  conditions {
    display_name = each.value.condition.display_name

    condition_threshold {
      filter          = each.value.condition.filter
      duration        = each.value.condition.duration
      comparison      = each.value.condition.comparison
      threshold_value = each.value.condition.threshold_value

      aggregations {
        alignment_period     = each.value.condition.alignment_period
        per_series_aligner   = each.value.condition.per_series_aligner
        cross_series_reducer = each.value.condition.cross_series_reducer
        group_by_fields     = each.value.condition.group_by_fields
      }

      trigger {
        count   = each.value.condition.trigger.count
        percent = each.value.condition.trigger.percent
      }
    }
  }

  notification_channels = each.value.notification_channels
  
  user_labels = each.value.labels
}

resource "google_monitoring_notification_channel" "notification_channel" {
  for_each = var.notification_channels

  display_name = each.value.display_name
  type         = each.value.type
  project      = var.project_id
  
  labels = each.value.labels

  dynamic "sensitive_labels" {
    for_each = each.value.sensitive_labels != null ? [each.value.sensitive_labels] : []
    content {
      auth_token  = sensitive_labels.value.auth_token
      password    = sensitive_labels.value.password
      service_key = sensitive_labels.value.service_key
    }
  }

  user_labels = each.value.user_labels
  enabled     = each.value.enabled

  verification_status = each.value.verification_status
}

resource "google_monitoring_uptime_check_config" "uptime_check" {
  for_each = var.uptime_checks

  display_name = each.value.display_name
  project      = var.project_id
  timeout      = each.value.timeout
  period       = each.value.period

  dynamic "http_check" {
    for_each = each.value.http_check != null ? [each.value.http_check] : []
    content {
      path         = http_check.value.path
      port         = http_check.value.port
      use_ssl      = http_check.value.use_ssl
      validate_ssl = http_check.value.validate_ssl
      headers      = http_check.value.headers
    }
  }

  dynamic "tcp_check" {
    for_each = each.value.tcp_check != null ? [each.value.tcp_check] : []
    content {
      port = tcp_check.value.port
    }
  }

  monitored_resource {
    type = each.value.monitored_resource.type
    labels = each.value.monitored_resource.labels
  }

  selected_regions = each.value.selected_regions
}
