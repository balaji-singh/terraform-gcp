include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/security/identity_aware_proxy"
}

dependency "network" {
  config_path = "../network"
}

inputs = {
  iap_settings = {
    "web-backend" = {
      oauth2_client_id = "client-id"
      oauth2_client_secret = "client-secret"
      brand = {
        support_email = "support@example.com"
        application_title = "Enterprise Application"
      }
    }
  }

  iap_tunnel = {
    "secure-tunnel" = {
      name = "secure-tunnel"
      network = dependency.network.outputs.network_name
      target_service = {
        name = "backend-service"
        port_range = "443"
      }
    }
  }

  identity_config = {
    oauth = {
      client_id = "client-id"
      client_secret = "client-secret"
      authorized_domains = ["example.com"]
    }
    groups = {
      "admin-group" = {
        display_name = "Admin Group"
        parent = "folders/12345"
        roles = ["roles/iap.admin"]
      }
      "user-group" = {
        display_name = "User Group"
        parent = "folders/12345"
        roles = ["roles/iap.httpsResourceAccessor"]
      }
    }
  }

  security_policies = {
    "iap-policy" = {
      name = "iap-security-policy"
      rules = [
        {
          priority = 1000
          description = "Allow internal IPs"
          match = {
            config = {
              src_ip_ranges = ["10.0.0.0/8"]
            }
          }
          action = "allow"
        }
      ]
    }
  }

  access_settings = {
    "web-settings" = {
      cors = {
        allowed_origins = ["https://example.com"]
        allowed_methods = ["GET", "POST"]
        allowed_headers = ["Authorization"]
        max_age = 3600
      }
      security_headers = {
        strict_transport_security = "max-age=31536000; includeSubDomains"
        content_security_policy = "default-src 'self'"
      }
    }
  }

  monitoring_config = {
    metrics = {
      "iap_requests" = {
        type = "custom.googleapis.com/iap/request_count"
        description = "IAP request count"
      }
      "iap_latency" = {
        type = "custom.googleapis.com/iap/latency"
        description = "IAP request latency"
      }
    }
    alerts = {
      "unauthorized_access" = {
        condition = "resource.type=iap_tunnel AND severity=ERROR"
        notification_channels = ["email", "slack"]
      }
    }
  }

  audit_config = {
    "iap-audit" = {
      log_type = "data_access"
      filter = "resource.type=iap_tunnel"
      destination = "logging.googleapis.com"
    }
  }
}
