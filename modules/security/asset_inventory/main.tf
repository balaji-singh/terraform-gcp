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

# Feed Level IAM
resource "google_cloud_asset_organization_feed" "organization_feed" {
  for_each = var.organization_feeds

  billing_project = var.billing_project
  org_id         = var.organization_id
  feed_id        = each.key
  content_type   = each.value.content_type

  feed_output_config {
    dynamic "pubsub_destination" {
      for_each = each.value.pubsub_destination != null ? [each.value.pubsub_destination] : []
      content {
        topic = pubsub_destination.value.topic
      }
    }
  }

  asset_types  = each.value.asset_types
  condition {
    expression  = each.value.condition.expression
    title       = each.value.condition.title
    description = each.value.condition.description
  }
}

resource "google_cloud_asset_folder_feed" "folder_feed" {
  for_each = var.folder_feeds

  billing_project = var.billing_project
  folder          = each.value.folder
  feed_id         = each.key
  content_type    = each.value.content_type

  feed_output_config {
    dynamic "pubsub_destination" {
      for_each = each.value.pubsub_destination != null ? [each.value.pubsub_destination] : []
      content {
        topic = pubsub_destination.value.topic
      }
    }
  }

  asset_types = each.value.asset_types
  condition {
    expression  = each.value.condition.expression
    title       = each.value.condition.title
    description = each.value.condition.description
  }
}

resource "google_cloud_asset_project_feed" "project_feed" {
  for_each = var.project_feeds

  project      = var.project_id
  feed_id      = each.key
  content_type = each.value.content_type

  feed_output_config {
    dynamic "pubsub_destination" {
      for_each = each.value.pubsub_destination != null ? [each.value.pubsub_destination] : []
      content {
        topic = pubsub_destination.value.topic
      }
    }
  }

  asset_types = each.value.asset_types
  condition {
    expression  = each.value.condition.expression
    title       = each.value.condition.title
    description = each.value.condition.description
  }
}

# IAM Policy Analysis
resource "google_cloud_asset_organization_saved_query" "organization_query" {
  for_each = var.organization_saved_queries

  organization = var.organization_id
  query_id     = each.key
  description  = each.value.description
  
  dynamic "content" {
    for_each = each.value.content != null ? [each.value.content] : []
    content {
      iam_policy_analysis_query {
        access_selector {
          permissions = content.value.permissions
          roles      = content.value.roles
        }
        condition_context {
          access_time = content.value.access_time
        }
        identity_selector {
          identity = content.value.identity
        }
        resource_selector {
          full_resource_name = content.value.full_resource_name
        }
      }
    }
  }
}

resource "google_cloud_asset_project_saved_query" "project_query" {
  for_each = var.project_saved_queries

  project     = var.project_id
  query_id    = each.key
  description = each.value.description
  
  dynamic "content" {
    for_each = each.value.content != null ? [each.value.content] : []
    content {
      iam_policy_analysis_query {
        access_selector {
          permissions = content.value.permissions
          roles      = content.value.roles
        }
        condition_context {
          access_time = content.value.access_time
        }
        identity_selector {
          identity = content.value.identity
        }
        resource_selector {
          full_resource_name = content.value.full_resource_name
        }
      }
    }
  }
}

# Real-time Feed IAM bindings
resource "google_cloud_asset_feed_iam_binding" "feed_iam" {
  for_each = var.feed_iam_bindings

  feed = each.value.feed_name
  role = each.value.role
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
