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

# Binary Authorization Policy
resource "google_binary_authorization_policy" "policy" {
  project = var.project_id

  global_policy_evaluation_mode = var.global_policy_evaluation_mode
  description                  = var.description

  # Default admission rule
  default_admission_rule {
    evaluation_mode  = var.default_admission_rule.evaluation_mode
    enforcement_mode = var.default_admission_rule.enforcement_mode
    require_attestations_by = var.default_admission_rule.require_attestations_by
  }

  # Cluster admission rules
  dynamic "cluster_admission_rules" {
    for_each = var.cluster_admission_rules
    content {
      cluster                  = cluster_admission_rules.key
      evaluation_mode          = cluster_admission_rules.value.evaluation_mode
      enforcement_mode         = cluster_admission_rules.value.enforcement_mode
      require_attestations_by  = cluster_admission_rules.value.require_attestations_by
    }
  }

  # Admission whitelist patterns
  dynamic "admission_whitelist_patterns" {
    for_each = var.admission_whitelist_patterns
    content {
      name_pattern = admission_whitelist_patterns.value
    }
  }
}

# Attestors
resource "google_binary_authorization_attestor" "attestors" {
  for_each = var.attestors

  project = var.project_id
  name    = each.key
  description = each.value.description

  attestation_authority_note {
    note_reference = each.value.note_reference
    public_keys {
      dynamic "pkix_public_key" {
        for_each = each.value.public_keys
        content {
          public_key_pem      = pkix_public_key.value.public_key_pem
          signature_algorithm = pkix_public_key.value.signature_algorithm
        }
      }
      dynamic "ascii_armored_pgp_public_key" {
        for_each = each.value.ascii_armored_pgp_public_keys
        content {
          ascii_armored_pgp_public_key = ascii_armored_pgp_public_key.value
        }
      }
      id = each.value.key_id
      comment = each.value.comment
    }
  }
}

# Attestor IAM Bindings
resource "google_binary_authorization_attestor_iam_binding" "attestor_bindings" {
  for_each = var.attestor_iam_bindings

  project  = var.project_id
  attestor = google_binary_authorization_attestor.attestors[each.value.attestor_name].name
  role     = each.value.role
  members  = each.value.members

  condition {
    title       = lookup(each.value, "condition", null) != null ? each.value.condition.title : null
    description = lookup(each.value, "condition", null) != null ? each.value.condition.description : null
    expression  = lookup(each.value, "condition", null) != null ? each.value.condition.expression : null
  }
}
