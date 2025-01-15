provider "google" {
  project = var.project_id
  region  = var.region
}

module "asset_inventory" {
  source = "../../../modules/security/asset_inventory"

  project_id      = var.project_id
  organization_id = var.organization_id
  billing_project = var.project_id

  # Organization-level Asset Feeds
  organization_feeds = {
    "org-resources" = {
      content_type = "RESOURCE"
      pubsub_destination = {
        topic = "projects/${var.project_id}/topics/asset-feed"
      }
      asset_types = [
        "compute.googleapis.com/Instance",
        "storage.googleapis.com/Bucket",
        "iam.googleapis.com/ServiceAccount"
      ]
      condition = {
        expression  = "resource.location.startsWith('us-')"
        title       = "US Resources Only"
        description = "Monitor resources in US regions"
      }
    }
  }

  # Project-level Asset Feeds
  project_feeds = {
    "project-iam" = {
      content_type = "IAM_POLICY"
      pubsub_destination = {
        topic = "projects/${var.project_id}/topics/iam-feed"
      }
      asset_types = ["*"]
      condition = {
        expression  = "true"
        title       = "All IAM Changes"
        description = "Monitor all IAM policy changes"
      }
    }
  }

  # Organization-level Saved Queries
  organization_saved_queries = {
    "privileged-access" = {
      description = "Monitor privileged access"
      content = {
        permissions = ["resourcemanager.projects.delete"]
        roles      = ["roles/owner"]
        access_time = "2024-12-31T23:59:59Z"
        identity    = "user:*"
        full_resource_name = "//cloudresourcemanager.googleapis.com/organizations/${var.organization_id}"
      }
    }
  }

  # Project-level Saved Queries
  project_saved_queries = {
    "service-account-access" = {
      description = "Monitor service account access"
      content = {
        permissions = ["iam.serviceAccounts.actAs"]
        roles      = []
        access_time = "2024-12-31T23:59:59Z"
        identity    = "serviceAccount:*"
        full_resource_name = "//cloudresourcemanager.googleapis.com/projects/${var.project_id}"
      }
    }
  }

  # Feed IAM Bindings
  feed_iam_bindings = {
    "feed-viewer" = {
      feed_name = "organizations/${var.organization_id}/feeds/org-resources"
      role      = "roles/cloudasset.viewer"
      members   = ["group:security-team@example.com"]
      condition = {
        title       = "temporary_access"
        description = "Temporary access to view asset feed"
        expression  = "request.time < timestamp('2024-12-31T23:59:59Z')"
      }
    }
  }
}
