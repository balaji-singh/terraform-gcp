/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 */

# Project IAM Bindings
resource "google_project_iam_binding" "project_bindings" {
  for_each = var.project_roles

  project = var.project_id
  role    = each.key
  members = each.value

  condition {
    title       = lookup(var.project_role_conditions, each.key, null) != null ? var.project_role_conditions[each.key].title : null
    description = lookup(var.project_role_conditions, each.key, null) != null ? var.project_role_conditions[each.key].description : null
    expression  = lookup(var.project_role_conditions, each.key, null) != null ? var.project_role_conditions[each.key].expression : null
  }
}

# Service Account Creation and Management
resource "google_service_account" "service_accounts" {
  for_each = var.service_accounts

  account_id   = each.key
  display_name = each.value.display_name
  description  = each.value.description
  project      = var.project_id
}

resource "google_service_account_key" "keys" {
  for_each = {
    for sa_key in local.service_account_keys : "${sa_key.service_account_id}.${sa_key.key_id}" => sa_key
  }

  service_account_id = google_service_account.service_accounts[each.value.service_account_id].name
  key_algorithm      = each.value.key_algorithm
  public_key_type    = each.value.public_key_type
}

# Custom Role Definition
resource "google_project_iam_custom_role" "custom_roles" {
  for_each = var.custom_roles

  project     = var.project_id
  role_id     = each.key
  title       = each.value.title
  description = each.value.description
  permissions = each.value.permissions
  stage       = each.value.stage
}

# Service Account IAM Bindings
resource "google_service_account_iam_binding" "sa_bindings" {
  for_each = var.service_account_bindings

  service_account_id = google_service_account.service_accounts[each.value.service_account_id].name
  role               = each.value.role
  members            = each.value.members

  condition {
    title       = lookup(each.value, "condition", null) != null ? each.value.condition.title : null
    description = lookup(each.value, "condition", null) != null ? each.value.condition.description : null
    expression  = lookup(each.value, "condition", null) != null ? each.value.condition.expression : null
  }
}

# Workload Identity Pool
resource "google_iam_workload_identity_pool" "pools" {
  for_each = var.workload_identity_pools

  project                   = var.project_id
  workload_identity_pool_id = each.key
  display_name             = each.value.display_name
  description              = each.value.description
  disabled                 = each.value.disabled
}

resource "google_iam_workload_identity_pool_provider" "pool_providers" {
  for_each = var.workload_identity_pool_providers

  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.pools[each.value.pool_id].workload_identity_pool_id
  workload_identity_pool_provider_id = each.key
  display_name                       = each.value.display_name
  description                        = each.value.description
  disabled                          = each.value.disabled

  attribute_mapping = each.value.attribute_mapping
  attribute_condition = each.value.attribute_condition

  oidc {
    allowed_audiences = each.value.oidc_config.allowed_audiences
    issuer_uri       = each.value.oidc_config.issuer_uri
  }
}

locals {
  service_account_keys = flatten([
    for sa_id, sa in var.service_accounts : [
      for key in lookup(sa, "keys", []) : {
        service_account_id = sa_id
        key_id            = key.key_id
        key_algorithm     = lookup(key, "key_algorithm", "KEY_ALG_RSA_2048")
        public_key_type   = lookup(key, "public_key_type", "TYPE_X509_PEM_FILE")
      }
    ]
  ])
}
