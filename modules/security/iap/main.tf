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

# IAP OAuth Brand
resource "google_iap_brand" "brand" {
  count = var.create_brand ? 1 : 0

  project = var.project_id
  support_email = var.support_email
  application_title = var.application_title
}

# IAP OAuth Client
resource "google_iap_client" "client" {
  for_each = var.oauth_clients

  display_name = each.value.display_name
  brand        = var.create_brand ? google_iap_brand.brand[0].name : var.existing_brand_id
}

# IAP Web Backend Service IAM
resource "google_iap_web_backend_service_iam_binding" "backend_service_bindings" {
  for_each = var.backend_service_iam_bindings

  project = var.project_id
  web_backend_service = each.value.backend_service
  role    = each.value.role
  members = each.value.members
}

# IAP Web IAM
resource "google_iap_web_iam_binding" "web_bindings" {
  for_each = var.web_iam_bindings

  project = var.project_id
  role    = each.value.role
  members = each.value.members
}

# IAP Web Type App Engine IAM
resource "google_iap_web_type_app_engine_iam_binding" "app_engine_bindings" {
  for_each = var.app_engine_iam_bindings

  project = var.project_id
  app_id = each.value.app_id
  role    = each.value.role
  members = each.value.members
}

# IAP Web Type Compute IAM
resource "google_iap_web_type_compute_iam_binding" "compute_bindings" {
  for_each = var.compute_iam_bindings

  project = var.project_id
  role    = each.value.role
  members = each.value.members
}

# IAP Tunnel Instance IAM
resource "google_iap_tunnel_instance_iam_binding" "tunnel_instance_bindings" {
  for_each = var.tunnel_instance_iam_bindings

  project = var.project_id
  zone    = each.value.zone
  instance = each.value.instance
  role    = each.value.role
  members = each.value.members
}

# IAP Settings
resource "google_iap_web_iam_policy" "policy" {
  count = var.create_iap_policy ? 1 : 0

  project = var.project_id
  policy_data = var.iap_policy_data
}

# IAP Web Backend Service Settings
resource "google_iap_web_backend_service_config" "backend_service_config" {
  for_each = var.backend_service_configs

  project = var.project_id
  web_backend_service = each.value.backend_service
  
  dynamic "oauth2_client_id" {
    for_each = each.value.oauth2_client_id != null ? [each.value.oauth2_client_id] : []
    content {
      client_id = oauth2_client_id.value.client_id
      client_secret = oauth2_client_id.value.client_secret
    }
  }
}
