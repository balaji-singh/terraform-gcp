/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 */

# Cloud Armor Security Policy
resource "google_compute_security_policy" "policy" {
  name        = var.policy_name
  description = var.description
  project     = var.project_id

  # Default rule (must be last)
  rule {
    action      = var.default_rule_action
    priority    = 2147483647
    description = "Default rule, higher priority overrides it"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }

  # Custom rules
  dynamic "rule" {
    for_each = var.rules
    content {
      action      = rule.value.action
      priority    = rule.value.priority
      description = rule.value.description

      match {
        versioned_expr = rule.value.versioned_expr
        dynamic "config" {
          for_each = rule.value.config != null ? [rule.value.config] : []
          content {
            src_ip_ranges = config.value.src_ip_ranges
          }
        }
        dynamic "expr" {
          for_each = rule.value.expr != null ? [rule.value.expr] : []
          content {
            expression = expr.value.expression
          }
        }
      }

      dynamic "rate_limit_options" {
        for_each = rule.value.rate_limit_options != null ? [rule.value.rate_limit_options] : []
        content {
          rate_limit_threshold {
            count        = rate_limit_options.value.threshold_count
            interval_sec = rate_limit_options.value.threshold_interval_sec
          }
          conform_action   = rate_limit_options.value.conform_action
          exceed_action    = rate_limit_options.value.exceed_action
          enforce_on_key   = rate_limit_options.value.enforce_on_key
          enforce_on_key_name = rate_limit_options.value.enforce_on_key_name
        }
      }

      dynamic "redirect_options" {
        for_each = rule.value.redirect_options != null ? [rule.value.redirect_options] : []
        content {
          type   = redirect_options.value.type
          target = redirect_options.value.target
        }
      }

      dynamic "header_action" {
        for_each = rule.value.header_action != null ? [rule.value.header_action] : []
        content {
          dynamic "request_headers_to_adds" {
            for_each = header_action.value.request_headers_to_add != null ? header_action.value.request_headers_to_add : []
            content {
              header_name  = request_headers_to_adds.value.name
              header_value = request_headers_to_adds.value.value
            }
          }
        }
      }

      preview = rule.value.preview
    }
  }

  # Advanced options
  dynamic "adaptive_protection_config" {
    for_each = var.adaptive_protection_config != null ? [var.adaptive_protection_config] : []
    content {
      layer_7_ddos_defense_config {
        enable = adaptive_protection_config.value.enable_layer7_ddos
      }
    }
  }

  dynamic "recaptcha_options_config" {
    for_each = var.recaptcha_options_config != null ? [var.recaptcha_options_config] : []
    content {
      redirect_site_key = recaptcha_options_config.value.redirect_site_key
    }
  }
}

# Edge Security Policy
resource "google_compute_security_policy" "edge_policy" {
  count       = var.create_edge_policy ? 1 : 0
  name        = "${var.policy_name}-edge"
  description = "${var.description} (Edge Policy)"
  project     = var.project_id
  type        = "EDGE"

  rule {
    action      = var.default_rule_action
    priority    = 2147483647
    description = "Default rule for edge policy"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }

  dynamic "rule" {
    for_each = var.edge_rules
    content {
      action      = rule.value.action
      priority    = rule.value.priority
      description = rule.value.description

      match {
        versioned_expr = rule.value.versioned_expr
        dynamic "config" {
          for_each = rule.value.config != null ? [rule.value.config] : []
          content {
            src_ip_ranges = config.value.src_ip_ranges
          }
        }
      }
    }
  }
}
