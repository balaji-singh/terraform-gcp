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

# Organization Policies
resource "google_org_policy_policy" "org_policy" {
  for_each = var.organization_policies

  name   = each.value.name
  parent = "organizations/${var.organization_id}"

  spec {
    dynamic "rules" {
      for_each = each.value.rules
      content {
        enforce = rules.value.enforce
        
        dynamic "condition" {
          for_each = rules.value.condition != null ? [rules.value.condition] : []
          content {
            description = condition.value.description
            expression  = condition.value.expression
            location   = condition.value.location
            title      = condition.value.title
          }
        }

        dynamic "values" {
          for_each = rules.value.values != null ? [rules.value.values] : []
          content {
            allowed_values = values.value.allowed_values
            denied_values  = values.value.denied_values
          }
        }
      }
    }
  }
}

# Project Policies
resource "google_project_organization_policy" "project_policy" {
  for_each = var.project_policies

  project    = var.project_id
  constraint = each.key

  dynamic "boolean_policy" {
    for_each = each.value.boolean_policy != null ? [each.value.boolean_policy] : []
    content {
      enforced = boolean_policy.value.enforced
    }
  }

  dynamic "list_policy" {
    for_each = each.value.list_policy != null ? [each.value.list_policy] : []
    content {
      inherit_from_parent = list_policy.value.inherit_from_parent
      suggested_value     = list_policy.value.suggested_value
      
      dynamic "allow" {
        for_each = list_policy.value.allow != null ? [list_policy.value.allow] : []
        content {
          values = allow.value.values
          all    = allow.value.all
        }
      }

      dynamic "deny" {
        for_each = list_policy.value.deny != null ? [list_policy.value.deny] : []
        content {
          values = deny.value.values
          all    = deny.value.all
        }
      }
    }
  }

  dynamic "restore_policy" {
    for_each = each.value.restore_policy != null ? [each.value.restore_policy] : []
    content {
      default = restore_policy.value.default
    }
  }
}

# Folder Policies
resource "google_folder_organization_policy" "folder_policy" {
  for_each = var.folder_policies

  folder     = each.value.folder
  constraint = each.key

  dynamic "boolean_policy" {
    for_each = each.value.boolean_policy != null ? [each.value.boolean_policy] : []
    content {
      enforced = boolean_policy.value.enforced
    }
  }

  dynamic "list_policy" {
    for_each = each.value.list_policy != null ? [each.value.list_policy] : []
    content {
      inherit_from_parent = list_policy.value.inherit_from_parent
      suggested_value     = list_policy.value.suggested_value
      
      dynamic "allow" {
        for_each = list_policy.value.allow != null ? [list_policy.value.allow] : []
        content {
          values = allow.value.values
          all    = allow.value.all
        }
      }

      dynamic "deny" {
        for_each = list_policy.value.deny != null ? [list_policy.value.deny] : []
        content {
          values = deny.value.values
          all    = deny.value.all
        }
      }
    }
  }

  dynamic "restore_policy" {
    for_each = each.value.restore_policy != null ? [each.value.restore_policy] : []
    content {
      default = restore_policy.value.default
    }
  }
}
