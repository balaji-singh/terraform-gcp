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

# Secret Manager Secrets
resource "google_secret_manager_secret" "secrets" {
  for_each = var.secrets

  project   = var.project_id
  secret_id = each.key

  labels = merge(var.labels, each.value.labels)

  replication {
    dynamic "user_managed" {
      for_each = each.value.replication.user_managed != null ? [each.value.replication.user_managed] : []
      content {
        dynamic "replicas" {
          for_each = user_managed.value.replicas
          content {
            location = replicas.value.location
            dynamic "customer_managed_encryption" {
              for_each = replicas.value.customer_managed_encryption != null ? [replicas.value.customer_managed_encryption] : []
              content {
                kms_key_name = customer_managed_encryption.value.kms_key_name
              }
            }
          }
        }
      }
    }

    dynamic "automatic" {
      for_each = each.value.replication.automatic != null ? [each.value.replication.automatic] : []
      content {
        dynamic "customer_managed_encryption" {
          for_each = automatic.value.customer_managed_encryption != null ? [automatic.value.customer_managed_encryption] : []
          content {
            kms_key_name = customer_managed_encryption.value.kms_key_name
          }
        }
      }
    }
  }

  rotation {
    dynamic "rotation_schedule" {
      for_each = each.value.rotation != null ? [each.value.rotation] : []
      content {
        rotation_period = rotation_schedule.value.rotation_period
      }
    }
    next_rotation_time = each.value.next_rotation_time
  }

  topics {
    dynamic "topics" {
      for_each = each.value.topics != null ? each.value.topics : []
      content {
        name = topics.value.name
      }
    }
  }

  expire_time = each.value.expire_time
}

# Secret Versions
resource "google_secret_manager_secret_version" "versions" {
  for_each = {
    for version in local.secret_versions : "${version.secret_id}.${version.version}" => version
  }

  secret      = google_secret_manager_secret.secrets[each.value.secret_id].id
  secret_data = each.value.secret_data

  enabled = each.value.enabled
}

# IAM Bindings
resource "google_secret_manager_secret_iam_binding" "bindings" {
  for_each = var.iam_bindings

  project   = var.project_id
  secret_id = google_secret_manager_secret.secrets[each.value.secret_id].secret_id
  role      = each.value.role
  members   = each.value.members

  condition {
    title       = lookup(each.value, "condition", null) != null ? each.value.condition.title : null
    description = lookup(each.value, "condition", null) != null ? each.value.condition.description : null
    expression  = lookup(each.value, "condition", null) != null ? each.value.condition.expression : null
  }
}

locals {
  secret_versions = flatten([
    for secret_id, secret in var.secrets : [
      for version in secret.versions : {
        secret_id   = secret_id
        version     = version.version
        secret_data = version.secret_data
        enabled     = version.enabled
      }
    ]
  ])
}
