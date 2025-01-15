/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 */

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}

# Security Health Analytics Custom Module
resource "google_scc_source" "custom_module" {
  for_each = var.custom_modules

  organization = var.organization_id
  display_name = each.key
  description  = each.value.description

  dynamic "finding_config" {
    for_each = each.value.finding_configs
    content {
      finding_class_name = finding_config.value.finding_class_name
      severity          = finding_config.value.severity
      indicator {
        resource_type = finding_config.value.resource_type
        category      = finding_config.value.category
        properties    = finding_config.value.properties
      }
    }
  }
}

# Security Command Center Source IAM
resource "google_scc_source_iam_binding" "source_iam" {
  for_each = var.source_iam_bindings

  organization = var.organization_id
  source      = google_scc_source.custom_module[each.value.source].name
  role        = each.value.role
  members     = each.value.members

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}

# Security Health Analytics Notification Config
resource "google_scc_notification_config" "notification" {
  for_each = var.notification_configs

  organization = var.organization_id
  config_id    = each.key
  description  = each.value.description
  pubsub_topic = each.value.pubsub_topic

  streaming_config {
    filter = each.value.filter
  }
}

# Security Health Analytics Mute Config
resource "google_scc_mute_config" "mute_config" {
  for_each = var.mute_configs

  organization = var.organization_id
  mute_config_id = each.key
  description    = each.value.description
  filter        = each.value.filter

  dynamic "update_time" {
    for_each = each.value.update_time != null ? [each.value.update_time] : []
    content {
      seconds = update_time.value.seconds
      nanos   = update_time.value.nanos
    }
  }
}

# Security Health Analytics Finding
resource "google_scc_finding" "finding" {
  for_each = var.findings

  organization = var.organization_id
  source      = google_scc_source.custom_module[each.value.source].name
  finding_id  = each.key
  state       = each.value.state
  category    = each.value.category

  resource_name = each.value.resource_name
  
  event_time {
    seconds = each.value.event_time.seconds
    nanos   = each.value.event_time.nanos
  }

  severity    = each.value.severity
  source_properties = each.value.source_properties

  dynamic "security_marks" {
    for_each = each.value.security_marks != null ? [each.value.security_marks] : []
    content {
      marks = security_marks.value
    }
  }

  dynamic "external_uri" {
    for_each = each.value.external_uri != null ? [each.value.external_uri] : []
    content {
      uri = external_uri.value
    }
  }
}
