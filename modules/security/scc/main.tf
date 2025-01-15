/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 */

# Security Command Center Organization Settings
resource "google_scc_organization_settings" "organization_settings" {
  count = var.enable_organization_settings ? 1 : 0

  organization = var.organization_id
  
  enable_asset_discovery        = var.enable_asset_discovery
  asset_discovery_config_mode   = var.asset_discovery_config_mode
  asset_discovery_config_period = var.asset_discovery_config_period
}

# Security Command Center Sources
resource "google_scc_source" "sources" {
  for_each = var.sources

  organization = var.organization_id
  display_name = each.value.display_name
  description  = each.value.description
}

# Security Command Center Notification Configs
resource "google_scc_notification_config" "notification_configs" {
  for_each = var.notification_configs

  organization = var.organization_id
  config_id    = each.key
  description  = each.value.description
  pubsub_topic = each.value.pubsub_topic

  streaming_config {
    filter = each.value.filter
  }
}

# Security Command Center Findings
resource "google_scc_finding" "findings" {
  for_each = var.findings

  source_id     = google_scc_source.sources[each.value.source_name].name
  finding_id    = each.key
  parent        = each.value.parent
  resource_name = each.value.resource_name
  state         = each.value.state
  category      = each.value.category

  event_time = each.value.event_time
  severity   = each.value.severity

  dynamic "security_marks" {
    for_each = each.value.security_marks != null ? [each.value.security_marks] : []
    content {
      marks = security_marks.value
    }
  }

  dynamic "source_properties" {
    for_each = each.value.source_properties != null ? [each.value.source_properties] : []
    content {
      properties = source_properties.value
    }
  }
}

# Security Command Center Mute Configs
resource "google_scc_mute_config" "mute_configs" {
  for_each = var.mute_configs

  parent     = each.value.parent
  config_id  = each.key
  filter     = each.value.filter
  description = each.value.description
}

# Security Command Center Source IAM Bindings
resource "google_scc_source_iam_binding" "source_iam_bindings" {
  for_each = var.source_iam_bindings

  source = google_scc_source.sources[each.value.source_name].name
  role   = each.value.role
  members = each.value.members

  condition {
    title       = lookup(each.value, "condition", null) != null ? each.value.condition.title : null
    description = lookup(each.value, "condition", null) != null ? each.value.condition.description : null
    expression  = lookup(each.value, "condition", null) != null ? each.value.condition.expression : null
  }
}

# Security Command Center Security Health Analytics Custom Modules
resource "google_scc_security_health_analytics_custom_module" "custom_modules" {
  for_each = var.custom_modules

  organization    = var.organization_id
  display_name    = each.value.display_name
  custom_config   = each.value.custom_config
  enablement_state = each.value.enablement_state
}
