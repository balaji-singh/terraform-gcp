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

# Access Policy
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
resource "google_access_context_manager_access_level" "levels" {
  for_each = var.access_levels

  parent = local.policy_id
  name   = "accessPolicies/${replace(local.policy_id, "accessPolicies/", "")}/accessLevels/${each.key}"
  title  = each.value.title

  basic {
    conditions {
      dynamic "ip_subnetworks" {
        for_each = each.value.ip_subnetworks != null ? [each.value.ip_subnetworks] : []
        content {
          ip_subnetworks = ip_subnetworks.value
        }
      }

      dynamic "required_access_levels" {
        for_each = each.value.required_access_levels != null ? [each.value.required_access_levels] : []
        content {
          access_levels = required_access_levels.value
        }
      }

      dynamic "members" {
        for_each = each.value.members != null ? [each.value.members] : []
        content {
          users   = members.value.users
          groups  = members.value.groups
          service_accounts = members.value.service_accounts
        }
      }

      regions = each.value.regions
      negate  = each.value.negate
    }

    combining_function = each.value.combining_function
  }
}

# Service Perimeters
resource "google_access_context_manager_service_perimeter" "regular" {
  for_each = var.service_perimeters

  parent = local.policy_id
  name   = "accessPolicies/${replace(local.policy_id, "accessPolicies/", "")}/servicePerimeters/${each.key}"
  title  = each.value.title
  perimeter_type = "PERIMETER_TYPE_REGULAR"

  status {
    restricted_services = each.value.restricted_services
    access_levels      = [for level in each.value.access_levels : google_access_context_manager_access_level.levels[level].name]
    
    dynamic "vpc_accessible_services" {
      for_each = each.value.vpc_accessible_services != null ? [each.value.vpc_accessible_services] : []
      content {
        enable_restriction = vpc_accessible_services.value.enable_restriction
        allowed_services  = vpc_accessible_services.value.allowed_services
      }
    }

    resources {
      dynamic "resource_type" {
        for_each = each.value.resources != null ? each.value.resources : []
        content {
          type   = resource_type.value.type
          values = resource_type.value.values
        }
      }
    }

    ingress_policies {
      dynamic "ingress_from" {
        for_each = each.value.ingress_policies != null ? each.value.ingress_policies : []
        content {
          sources {
            access_level = ingress_from.value.source_access_level
            resources   = ingress_from.value.source_resources
          }
          identity_type = ingress_from.value.identity_type
          identities    = ingress_from.value.identities
        }
      }
      dynamic "ingress_to" {
        for_each = each.value.ingress_to != null ? [each.value.ingress_to] : []
        content {
          resources = ingress_to.value.resources
          operations {
            service_name = ingress_to.value.service_name
            method_selectors {
              method = ingress_to.value.method
              permission = ingress_to.value.permission
            }
          }
        }
      }
    }

    egress_policies {
      dynamic "egress_from" {
        for_each = each.value.egress_policies != null ? each.value.egress_policies : []
        content {
          identity_type = egress_from.value.identity_type
          identities    = egress_from.value.identities
        }
      }
      dynamic "egress_to" {
        for_each = each.value.egress_to != null ? [each.value.egress_to] : []
        content {
          resources = egress_to.value.resources
          operations {
            service_name = egress_to.value.service_name
            method_selectors {
              method = egress_to.value.method
              permission = egress_to.value.permission
            }
          }
        }
      }
    }
  }

  use_explicit_dry_run_spec = each.value.use_explicit_dry_run_spec

  dynamic "spec" {
    for_each = each.value.spec != null ? [each.value.spec] : []
    content {
      restricted_services = spec.value.restricted_services
      access_levels      = [for level in spec.value.access_levels : google_access_context_manager_access_level.levels[level].name]
      resources          = spec.value.resources
      
      vpc_accessible_services {
        enable_restriction = spec.value.vpc_accessible_services.enable_restriction
        allowed_services  = spec.value.vpc_accessible_services.allowed_services
      }
    }
  }
}
