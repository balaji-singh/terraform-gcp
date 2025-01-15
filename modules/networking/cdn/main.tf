/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 */

resource "google_compute_backend_bucket" "cdn_backend" {
  name        = var.name
  description = var.description
  project     = var.project_id

  bucket_name = google_storage_bucket.cdn_bucket.name
  enable_cdn  = true

  cdn_policy {
    cache_mode                   = var.cache_mode
    client_ttl                   = var.client_ttl
    default_ttl                  = var.default_ttl
    max_ttl                      = var.max_ttl
    negative_caching            = var.negative_caching
    serve_while_stale          = var.serve_while_stale
    signed_url_cache_max_age_sec = var.signed_url_cache_max_age_sec

    dynamic "negative_caching_policy" {
      for_each = var.negative_caching_policies
      content {
        code = negative_caching_policy.value.code
        ttl  = negative_caching_policy.value.ttl
      }
    }

    dynamic "cache_key_policy" {
      for_each = var.cache_key_policy != null ? [var.cache_key_policy] : []
      content {
        include_host           = cache_key_policy.value.include_host
        include_protocol       = cache_key_policy.value.include_protocol
        include_query_string   = cache_key_policy.value.include_query_string
        query_string_whitelist = cache_key_policy.value.query_string_whitelist
        query_string_blacklist = cache_key_policy.value.query_string_blacklist
      }
    }
  }

  custom_response_headers = var.custom_response_headers
}

resource "google_storage_bucket" "cdn_bucket" {
  name                        = var.bucket_name
  project                     = var.project_id
  location                    = var.bucket_location
  storage_class              = var.storage_class
  uniform_bucket_level_access = true
  force_destroy              = var.force_destroy

  cors {
    origin          = var.cors_origins
    method          = var.cors_methods
    response_header = var.cors_response_headers
    max_age_seconds = var.cors_max_age_seconds
  }

  versioning {
    enabled = var.enable_versioning
  }

  lifecycle_rule {
    condition {
      age = var.object_age_days
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_compute_url_map" "cdn_url_map" {
  name            = "${var.name}-url-map"
  project         = var.project_id
  default_service = google_compute_backend_bucket.cdn_backend.self_link

  dynamic "host_rule" {
    for_each = var.host_rules
    content {
      hosts        = host_rule.value.hosts
      path_matcher = host_rule.value.path_matcher
    }
  }

  dynamic "path_matcher" {
    for_each = var.path_rules
    content {
      name            = path_matcher.key
      default_service = google_compute_backend_bucket.cdn_backend.self_link

      dynamic "path_rule" {
        for_each = path_matcher.value
        content {
          paths   = path_rule.value.paths
          service = google_compute_backend_bucket.cdn_backend.self_link
        }
      }
    }
  }
}

resource "google_compute_target_http_proxy" "cdn_http_proxy" {
  name    = "${var.name}-http-proxy"
  project = var.project_id
  url_map = google_compute_url_map.cdn_url_map.self_link
}

resource "google_compute_global_forwarding_rule" "cdn_forwarding_rule" {
  name       = "${var.name}-forwarding-rule"
  project    = var.project_id
  target     = google_compute_target_http_proxy.cdn_http_proxy.self_link
  port_range = "80"
  ip_address = var.create_ip ? google_compute_global_address.cdn_ip[0].address : var.ip_address
}

resource "google_compute_global_address" "cdn_ip" {
  count   = var.create_ip ? 1 : 0
  name    = "${var.name}-ip"
  project = var.project_id
}
