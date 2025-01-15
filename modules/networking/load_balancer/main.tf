/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 */

# HTTP(S) Load Balancer
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "${var.name}-forwarding-rule"
  project               = var.project_id
  target                = google_compute_target_http_proxy.default.id
  port_range            = "80"
  load_balancing_scheme = var.load_balancing_scheme
  ip_address            = var.create_address ? google_compute_global_address.default[0].address : var.address
}

resource "google_compute_global_address" "default" {
  count   = var.create_address ? 1 : 0
  name    = "${var.name}-address"
  project = var.project_id
}

resource "google_compute_target_http_proxy" "default" {
  name    = "${var.name}-http-proxy"
  project = var.project_id
  url_map = google_compute_url_map.default.id
}

resource "google_compute_url_map" "default" {
  name            = "${var.name}-url-map"
  project         = var.project_id
  default_service = google_compute_backend_service.default.id

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
      default_service = google_compute_backend_service.default.id

      dynamic "path_rule" {
        for_each = path_matcher.value
        content {
          paths   = path_rule.value.paths
          service = google_compute_backend_service.services[path_rule.value.service].id
        }
      }
    }
  }
}

resource "google_compute_backend_service" "default" {
  name                  = "${var.name}-backend"
  project               = var.project_id
  protocol              = var.backend_protocol
  port_name             = var.backend_port_name
  timeout_sec          = var.backend_timeout_sec
  enable_cdn           = var.enable_cdn
  health_checks        = [google_compute_health_check.default.id]
  load_balancing_scheme = var.load_balancing_scheme

  dynamic "backend" {
    for_each = var.backend_groups
    content {
      group           = backend.value.group
      balancing_mode  = backend.value.balancing_mode
      capacity_scaler = backend.value.capacity_scaler
    }
  }

  dynamic "cdn_policy" {
    for_each = var.enable_cdn ? [1] : []
    content {
      cache_mode                   = var.cdn_cache_mode
      client_ttl                   = var.cdn_client_ttl
      default_ttl                  = var.cdn_default_ttl
      max_ttl                      = var.cdn_max_ttl
      negative_caching            = var.cdn_negative_caching
      serve_while_stale          = var.cdn_serve_while_stale
    }
  }
}

resource "google_compute_backend_service" "services" {
  for_each = var.additional_backend_services

  name                  = "${var.name}-${each.key}-backend"
  project               = var.project_id
  protocol              = each.value.protocol
  port_name             = each.value.port_name
  timeout_sec          = each.value.timeout_sec
  enable_cdn           = each.value.enable_cdn
  health_checks        = [google_compute_health_check.default.id]
  load_balancing_scheme = var.load_balancing_scheme

  dynamic "backend" {
    for_each = each.value.backend_groups
    content {
      group           = backend.value.group
      balancing_mode  = backend.value.balancing_mode
      capacity_scaler = backend.value.capacity_scaler
    }
  }
}

resource "google_compute_health_check" "default" {
  name               = "${var.name}-health-check"
  project            = var.project_id
  check_interval_sec = var.health_check_interval_sec
  timeout_sec        = var.health_check_timeout_sec

  http_health_check {
    port         = var.health_check_port
    request_path = var.health_check_path
  }
}
