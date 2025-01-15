/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 */

resource "google_dns_managed_zone" "zone" {
  name        = var.zone_name
  dns_name    = var.dns_name
  description = var.description
  project     = var.project_id

  visibility = var.private_zone ? "private" : "public"

  dynamic "private_visibility_config" {
    for_each = var.private_zone ? [1] : []
    content {
      dynamic "networks" {
        for_each = var.networks
        content {
          network_url = networks.value
        }
      }
    }
  }

  dynamic "dnssec_config" {
    for_each = var.enable_dnssec ? [1] : []
    content {
      state = "on"
      default_key_specs {
        algorithm  = var.dnssec_key_algorithm
        key_length = var.dnssec_key_length
        key_type   = "keySigning"
      }
      default_key_specs {
        algorithm  = var.dnssec_key_algorithm
        key_length = var.dnssec_key_length
        key_type   = "zoneSigning"
      }
    }
  }

  force_destroy = var.force_destroy
  labels        = var.labels
}

resource "google_dns_record_set" "records" {
  for_each = { for record in var.records : "${record.name}-${record.type}" => record }

  project      = var.project_id
  managed_zone = google_dns_managed_zone.zone.name
  name         = each.value.name
  type         = each.value.type
  ttl          = each.value.ttl
  rrdatas      = each.value.records

  depends_on = [google_dns_managed_zone.zone]
}

resource "google_dns_policy" "policy" {
  count = var.enable_inbound_forwarding ? 1 : 0

  project                   = var.project_id
  name                     = "${var.zone_name}-policy"
  enable_inbound_forwarding = true
  
  dynamic "networks" {
    for_each = var.networks
    content {
      network_url = networks.value
    }
  }
}
