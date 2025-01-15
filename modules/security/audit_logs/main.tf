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

# Project Audit Logs Config
resource "google_project_iam_audit_config" "project_audit_logs" {
  for_each = var.project_audit_configs

  project = var.project_id
  service = each.key

  dynamic "audit_log_config" {
    for_each = each.value.log_configs
    content {
      log_type         = audit_log_config.value.log_type
      exempted_members = audit_log_config.value.exempted_members
    }
  }
}

# Organization Audit Logs Config
resource "google_organization_iam_audit_config" "org_audit_logs" {
  for_each = var.organization_audit_configs

  org_id = var.organization_id
  service = each.key

  dynamic "audit_log_config" {
    for_each = each.value.log_configs
    content {
      log_type         = audit_log_config.value.log_type
      exempted_members = audit_log_config.value.exempted_members
    }
  }
}

# Folder Audit Logs Config
resource "google_folder_iam_audit_config" "folder_audit_logs" {
  for_each = var.folder_audit_configs

  folder = each.value.folder_id
  service = each.key

  dynamic "audit_log_config" {
    for_each = each.value.log_configs
    content {
      log_type         = audit_log_config.value.log_type
      exempted_members = audit_log_config.value.exempted_members
    }
  }
}

# Logging Sinks
resource "google_logging_project_sink" "project_sink" {
  for_each = var.project_sinks

  project = var.project_id
  name    = each.key
  destination = each.value.destination
  filter  = each.value.filter

  unique_writer_identity = each.value.unique_writer_identity

  dynamic "exclusions" {
    for_each = each.value.exclusions != null ? each.value.exclusions : []
    content {
      name        = exclusions.value.name
      description = exclusions.value.description
      filter      = exclusions.value.filter
      disabled    = exclusions.value.disabled
    }
  }

  bigquery_options {
    use_partitioned_tables = each.value.use_partitioned_tables
  }
}

# Logging Metrics
resource "google_logging_metric" "logging_metric" {
  for_each = var.logging_metrics

  project = var.project_id
  name    = each.key
  filter  = each.value.filter
  description = each.value.description

  metric_descriptor {
    metric_kind = each.value.metric_kind
    value_type  = each.value.value_type
    unit        = each.value.unit
    labels {
      key         = each.value.label_key
      value_type  = each.value.label_value_type
      description = each.value.label_description
    }
  }

  dynamic "label_extractors" {
    for_each = each.value.label_extractors != null ? [each.value.label_extractors] : []
    content {
      dynamic "extract" {
        for_each = label_extractors.value
        content {
          label_name  = extract.key
          regex       = extract.value
        }
      }
    }
  }
}

# Logging Buckets
resource "google_logging_project_bucket_config" "logging_bucket" {
  for_each = var.logging_buckets

  project        = var.project_id
  location       = each.value.location
  retention_days = each.value.retention_days
  bucket_id      = each.key

  dynamic "cmek_settings" {
    for_each = each.value.kms_key_name != null ? [each.value.kms_key_name] : []
    content {
      kms_key_name = cmek_settings.value
    }
  }
}
