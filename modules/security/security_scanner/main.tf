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

# Web Security Scanner Scan Config
resource "google_security_scanner_scan_config" "scan_config" {
  for_each = var.scan_configs

  project        = var.project_id
  display_name   = each.key
  starting_urls  = each.value.starting_urls
  target_platforms = each.value.target_platforms

  authentication {
    dynamic "google_account" {
      for_each = each.value.google_account != null ? [each.value.google_account] : []
      content {
        username = google_account.value.username
        password = google_account.value.password
      }
    }

    dynamic "custom_account" {
      for_each = each.value.custom_account != null ? [each.value.custom_account] : []
      content {
        username = custom_account.value.username
        password = custom_account.value.password
        login_url = custom_account.value.login_url
      }
    }
  }

  schedule {
    schedule_time = each.value.schedule_time
    interval      = each.value.schedule_interval
  }

  user_agent = each.value.user_agent

  dynamic "blacklist_patterns" {
    for_each = each.value.blacklist_patterns != null ? [each.value.blacklist_patterns] : []
    content {
      pattern = blacklist_patterns.value
    }
  }

  max_qps = each.value.max_qps

  dynamic "export_to_security_command_center" {
    for_each = each.value.export_to_security_command_center != null ? [each.value.export_to_security_command_center] : []
    content {
      enable = export_to_security_command_center.value.enable
      filter = export_to_security_command_center.value.filter
    }
  }

  risk_level = each.value.risk_level
  managed_scan = each.value.managed_scan
}

# Web Security Scanner Scan Run
resource "google_security_scanner_scan_run" "scan_run" {
  for_each = var.scan_runs

  scan_config = google_security_scanner_scan_config.scan_config[each.value.scan_config].name
  execution_state = each.value.execution_state
}

# Web Security Scanner IAM
resource "google_security_scanner_scan_config_iam_binding" "scan_config_iam" {
  for_each = var.scan_config_iam_bindings

  scan_config = google_security_scanner_scan_config.scan_config[each.value.scan_config].name
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
