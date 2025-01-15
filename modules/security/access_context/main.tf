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

# Access Context Manager Access Policy
resource "google_access_context_manager_access_policy" "policy" {
  count  = var.create_access_policy ? 1 : 0
  parent = "organizations/${var.organization_id}"
  title  = var.policy_title
  scopes = var.policy_scopes
}

locals {
  policy_id = var.create_access_policy ? google_access_context_manager_access_policy.policy[0].name : var.existing_policy_id
}

# Access Levels
resource "google_access_context_manager_access_level" "custom" {
  for_each = var.custom_access_levels

  parent = local.policy_id
  name   = "accessPolicies/${replace(local.policy_id, "accessPolicies/", "")}/accessLevels/${each.key}"
  title  = each.value.title

  dynamic "basic" {
    for_each = each.value.basic != null ? [each.value.basic] : []
    content {
      dynamic "conditions" {
        for_each = basic.value.conditions
        content {
          device_policy {
            dynamic "os_constraints" {
              for_each = conditions.value.os_constraints != null ? conditions.value.os_constraints : []
              content {
                os_type                    = os_constraints.value.os_type
                minimum_version           = os_constraints.value.minimum_version
                require_verified_chrome_os = os_constraints.value.require_verified_chrome_os
              }
            }
            require_screen_lock              = conditions.value.require_screen_lock
            allowed_encryption_statuses      = conditions.value.allowed_encryption_statuses
            allowed_device_management_levels = conditions.value.allowed_device_management_levels
            require_admin_approval          = conditions.value.require_admin_approval
            require_corp_owned              = conditions.value.require_corp_owned
          }

          ip_subnetworks         = conditions.value.ip_subnetworks
          required_access_levels = conditions.value.required_access_levels
          members               = conditions.value.members
          negate                = conditions.value.negate
          regions              = conditions.value.regions
        }
      }
      combining_function = basic.value.combining_function
    }
  }

  dynamic "custom" {
    for_each = each.value.custom != null ? [each.value.custom] : []
    content {
      expr {
        expression = custom.value.expression
        title      = custom.value.title
        location   = custom.value.location
      }
    }
  }
}

# GCP Resources Access Levels
resource "google_access_context_manager_gcp_user_access_binding" "binding" {
  for_each = var.gcp_user_access_bindings

  organization_id = var.organization_id
  group_key      = each.value.group_key
  access_levels  = [for level in each.value.access_levels : google_access_context_manager_access_level.custom[level].name]
}

# Service Perimeter Bridge
resource "google_access_context_manager_service_perimeter_resource" "bridge" {
  for_each = var.service_perimeter_bridges

  perimeter_name = each.value.perimeter_name
  resource      = each.value.resource
}

# Access Policy IAM
resource "google_access_context_manager_access_policy_iam_binding" "policy_iam" {
  for_each = var.access_policy_iam_bindings

  name  = local.policy_id
  role  = each.value.role
  members = each.value.members

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      title       = condition.value.title
      description = condition.value.description
      expression  = condition.value.expression
    }
  }
}
