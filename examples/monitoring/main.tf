provider "google" {
  project = var.project_id
  region  = var.region
}

module "monitoring" {
  source = "../../../modules/monitoring"

  project_id = var.project_id

  # Dashboards
  dashboards = {
    "app-dashboard" = {
      display_name = "Application Dashboard"
      grid_layout = {
        columns = 2
        widgets = [
          {
            title = "CPU Usage"
            xyChart = {
              dataSets = [{
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\""
                  }
                }
              }]
            }
          }
        ]
      }
    }
  }

  # Alert Policies
  alert_policies = {
    "high-cpu" = {
      display_name = "High CPU Usage Alert"
      enabled      = true
      documentation = {
        content   = "CPU usage is above threshold"
        mime_type = "text/markdown"
      }
      condition = {
        display_name     = "CPU Usage > 80%"
        filter           = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\""
        duration        = "300s"
        comparison      = "COMPARISON_GT"
        threshold_value = 0.8
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_MEAN"
        group_by_fields     = ["resource.instance_id"]
        trigger = {
          count   = 1
          percent = 0
        }
      }
      notification_channels = []
      labels = {
        severity = "critical"
      }
    }
  }

  # Notification Channels
  notification_channels = {
    "email" = {
      display_name = "DevOps Team Email"
      type         = "email"
      labels = {
        email_address = "devops@example.com"
      }
      sensitive_labels = null
      user_labels = {
        team = "devops"
      }
      enabled = true
      verification_status = "VERIFIED"
    }
  }

  # Uptime Checks
  uptime_checks = {
    "website" = {
      display_name = "Website Health Check"
      timeout      = "10s"
      period       = "300s"
      http_check = {
        path         = "/health"
        port         = 443
        use_ssl      = true
        validate_ssl = true
        headers      = {}
      }
      tcp_check = null
      monitored_resource = {
        type = "uptime_url"
        labels = {
          host = "example.com"
          project_id = var.project_id
        }
      }
      selected_regions = ["us-central1", "europe-west1"]
    }
  }
}
