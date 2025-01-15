/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 */

# KMS Key Ring
resource "google_kms_key_ring" "key_ring" {
  name     = var.key_ring_name
  location = var.location
  project  = var.project_id
}

# KMS Crypto Keys
resource "google_kms_crypto_key" "crypto_keys" {
  for_each = var.crypto_keys

  name            = each.key
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = each.value.rotation_period
  labels          = each.value.labels

  purpose = each.value.purpose
  
  version_template {
    algorithm        = each.value.version_template.algorithm
    protection_level = each.value.version_template.protection_level
  }

  dynamic "import_only" {
    for_each = each.value.import_only != null ? [each.value.import_only] : []
    content {
      rsa_aes_wrapped_key = import_only.value.rsa_aes_wrapped_key
    }
  }

  destroy_scheduled_duration = each.value.destroy_scheduled_duration
  skip_initial_version_creation = each.value.skip_initial_version_creation

  lifecycle {
    prevent_destroy = true
  }
}

# KMS Crypto Key IAM Bindings
resource "google_kms_crypto_key_iam_binding" "crypto_key_bindings" {
  for_each = var.crypto_key_iam_bindings

  crypto_key_id = google_kms_crypto_key.crypto_keys[each.value.crypto_key_name].id
  role          = each.value.role
  members       = each.value.members

  condition {
    title       = lookup(each.value, "condition", null) != null ? each.value.condition.title : null
    description = lookup(each.value, "condition", null) != null ? each.value.condition.description : null
    expression  = lookup(each.value, "condition", null) != null ? each.value.condition.expression : null
  }
}

# Key Ring IAM Bindings
resource "google_kms_key_ring_iam_binding" "key_ring_bindings" {
  for_each = var.key_ring_iam_bindings

  key_ring_id = google_kms_key_ring.key_ring.id
  role        = each.value.role
  members     = each.value.members

  condition {
    title       = lookup(each.value, "condition", null) != null ? each.value.condition.title : null
    description = lookup(each.value, "condition", null) != null ? each.value.condition.description : null
    expression  = lookup(each.value, "condition", null) != null ? each.value.condition.expression : null
  }
}

# Import Jobs
resource "google_kms_key_ring_import_job" "import_jobs" {
  for_each = var.import_jobs

  key_ring      = google_kms_key_ring.key_ring.id
  import_job_id = each.key

  import_method = each.value.import_method
  protection_level = each.value.protection_level

  expires_at = each.value.expires_at
}
