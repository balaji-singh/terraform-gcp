/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 */

resource "google_storage_bucket" "bucket" {
  name                        = var.name
  project                     = var.project_id
  location                    = var.location
  storage_class              = var.storage_class
  uniform_bucket_level_access = var.uniform_bucket_level_access
  force_destroy              = var.force_destroy

  dynamic "versioning" {
    for_each = var.versioning ? [1] : []
    content {
      enabled = true
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      condition {
        age                   = lookup(lifecycle_rule.value.condition, "age", null)
        created_before        = lookup(lifecycle_rule.value.condition, "created_before", null)
        with_state           = lookup(lifecycle_rule.value.condition, "with_state", null)
        matches_storage_class = lookup(lifecycle_rule.value.condition, "matches_storage_class", null)
        num_newer_versions    = lookup(lifecycle_rule.value.condition, "num_newer_versions", null)
      }

      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lookup(lifecycle_rule.value.action, "storage_class", null)
      }
    }
  }

  dynamic "encryption" {
    for_each = var.encryption != null ? [var.encryption] : []
    content {
      default_kms_key_name = encryption.value
    }
  }

  dynamic "cors" {
    for_each = var.cors
    content {
      origin          = cors.value.origin
      method          = cors.value.method
      response_header = cors.value.response_header
      max_age_seconds = cors.value.max_age_seconds
    }
  }

  labels = var.labels
}
