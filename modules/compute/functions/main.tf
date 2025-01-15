/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 */

resource "google_storage_bucket" "function_bucket" {
  count = var.create_bucket ? 1 : 0

  name                        = "${var.project_id}-${var.function_name}-source"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy              = true
}

data "archive_file" "function_archive" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = var.archive_path
}

resource "google_storage_bucket_object" "function_source" {
  name   = "function-source-${data.archive_file.function_archive.output_md5}.zip"
  bucket = var.create_bucket ? google_storage_bucket.function_bucket[0].name : var.bucket_name
  source = data.archive_file.function_archive.output_path
}

resource "google_cloudfunctions2_function" "function" {
  name        = var.function_name
  location    = var.region
  description = var.description
  project     = var.project_id

  build_config {
    runtime     = var.runtime
    entry_point = var.entry_point
    source {
      storage_source {
        bucket = var.create_bucket ? google_storage_bucket.function_bucket[0].name : var.bucket_name
        object = google_storage_bucket_object.function_source.name
      }
    }
  }

  service_config {
    max_instance_count             = var.max_instance_count
    min_instance_count             = var.min_instance_count
    available_memory               = var.available_memory
    timeout_seconds                = var.timeout_seconds
    environment_variables          = var.environment_variables
    ingress_settings              = var.ingress_settings
    all_traffic_on_latest_revision = true
    service_account_email         = var.service_account_email

    dynamic "secret_environment_variables" {
      for_each = var.secret_environment_variables
      content {
        key        = secret_environment_variables.value.key
        project_id = secret_environment_variables.value.project_id
        secret     = secret_environment_variables.value.secret
        version    = secret_environment_variables.value.version
      }
    }
  }

  event_trigger {
    trigger_region = var.region
    event_type    = var.event_type
    retry_policy  = var.retry_policy
    service_account_email = var.trigger_service_account_email

    dynamic "event_filters" {
      for_each = var.event_filters
      content {
        attribute = event_filters.value.attribute
        value     = event_filters.value.value
      }
    }
  }

  labels = var.labels
}
