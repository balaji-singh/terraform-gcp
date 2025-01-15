include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/security/cloud_asset"
}

inputs = {
  feeds = {
    "asset-changes" = {
      feed_id = "asset-changes"
      content_type = "RESOURCE"
      asset_types = [
        "compute.googleapis.com/Instance",
        "storage.googleapis.com/Bucket",
        "iam.googleapis.com/ServiceAccount"
      ]
      feed_output_config = {
        pubsub_destination = {
          topic = "projects/${local.project_id}/topics/asset-changes"
        }
      }
      condition = {
        expression = "resource.asset_type.matches('compute.googleapis.com/.*') OR resource.asset_type.matches('storage.googleapis.com/.*')"
      }
    }
    "iam-changes" = {
      feed_id = "iam-changes"
      content_type = "IAM_POLICY"
      asset_types = ["*"]
      feed_output_config = {
        pubsub_destination = {
          topic = "projects/${local.project_id}/topics/iam-changes"
        }
      }
    }
  }

  analysis_config = {
    "security-analysis" = {
      analysis_query = {
        scope = "projects/${local.project_id}"
        asset_types = ["*"]
        condition = {
          expression = "resource.security_level = 'HIGH'"
        }
        output_config = {
          gcs_destination = {
            uri = "gs://${local.project_id}-security-analysis/reports"
          }
        }
      }
      schedule = "daily"
    }
  }

  export_config = {
    "daily-export" = {
      snapshot_time = timeadd(timestamp(), "24h")
      content_type = "RESOURCE"
      asset_types = ["*"]
      output_config = {
        gcs_destination = {
          uri = "gs://${local.project_id}-asset-export/daily"
        }
      }
    }
  }

  real_time_config = {
    "asset-updates" = {
      asset_types = ["*"]
      content_type = "RESOURCE"
      destination = {
        pubsub_topic = "projects/${local.project_id}/topics/asset-updates"
      }
    }
  }

  monitoring_config = {
    metrics = {
      "asset_changes" = {
        type = "custom.googleapis.com/asset/changes"
        description = "Asset inventory changes"
      }
    }
    alerts = {
      "critical_change" = {
        condition = "resource.type=cloud_asset AND severity=CRITICAL"
        notification_channels = ["email", "slack"]
      }
    }
  }

  compliance_config = {
    "asset-compliance" = {
      standards = ["CIS", "SOC2", "HIPAA"]
      checks = [
        "public_access",
        "encryption",
        "iam_policy"
      ]
      reporting = {
        enabled = true
        frequency = "daily"
        recipients = ["compliance@example.com"]
      }
    }
  }

  audit_config = {
    "asset-audit" = {
      log_type = "data_access"
      filter = "resource.type=cloud_asset"
      destination = "logging.googleapis.com"
    }
  }
}
