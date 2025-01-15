/**
 * Network Security Controls Configuration
 * This example demonstrates comprehensive network security controls
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

provider "google" {
  project = var.project_id
  region  = var.region
}

# Cloud Armor Security Policies
module "cloud_armor" {
  source = "../../../modules/security/cloud_armor"

  project_id = var.project_id

  security_policies = {
    "waf-policy" = {
      description = "WAF security policy"
      type        = "CLOUD_ARMOR"
      rules = [
        {
          action      = "deny(403)"
          priority    = 1000
          description = "Block SQL injection"
          expression  = "evaluatePreconfiguredExpr('sqli-stable')"
        },
        {
          action      = "deny(403)"
          priority    = 1001
          description = "Block XSS"
          expression  = "evaluatePreconfiguredExpr('xss-stable')"
        },
        {
          action      = "deny(403)"
          priority    = 1002
          description = "Block remote file inclusion"
          expression  = "evaluatePreconfiguredExpr('rfi-stable')"
        },
        {
          action      = "deny(403)"
          priority    = 2000
          description = "Block specified countries"
          expression  = "origin.region_code == 'CN' || origin.region_code == 'RU'"
        }
      ]

      adaptive_protection_config = {
        layer_7_ddos_defense_config = {
          enable = true
          rule_visibility = "STANDARD"
        }
      }

      rate_limiting_config = {
        enforce_on_key = "IP"
        rate_limit = 100
        ban_duration_sec = 300
      }
    }
  }
}

# VPC Network Security
module "network_security" {
  source = "../../../modules/security/network"

  project_id = var.project_id
  network_name = var.network_name

  subnets = {
    "private-subnet" = {
      name          = "private-subnet"
      ip_cidr_range = "10.0.1.0/24"
      region        = var.region
      private_ip_google_access = true
    }
    "restricted-subnet" = {
      name          = "restricted-subnet"
      ip_cidr_range = "10.0.2.0/24"
      region        = var.region
      private_ip_google_access = true
    }
  }

  firewall_rules = {
    "allow-internal" = {
      name        = "allow-internal"
      description = "Allow internal traffic"
      direction   = "INGRESS"
      priority    = 1000
      ranges      = ["10.0.0.0/8"]
      allow = [{
        protocol = "tcp"
        ports    = ["0-65535"]
      }]
    }
    "deny-external" = {
      name        = "deny-external"
      description = "Deny external traffic"
      direction   = "INGRESS"
      priority    = 2000
      ranges      = ["0.0.0.0/0"]
      deny = [{
        protocol = "all"
      }]
    }
  }

  routes = {
    "private-internet" = {
      name              = "private-internet"
      description       = "Route through NAT Gateway"
      dest_range        = "0.0.0.0/0"
      next_hop_gateway  = "default-internet-gateway"
      priority          = 1000
    }
  }
}

# Cloud NAT Configuration
module "cloud_nat" {
  source = "../../../modules/security/cloud_nat"

  project_id = var.project_id
  region     = var.region
  network    = module.network_security.network.name

  nat_configs = {
    "secure-nat" = {
      name = "secure-nat"
      source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
      subnetworks = [
        {
          name = module.network_security.subnets["private-subnet"].self_link
          source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE"]
        }
      ]
      log_config = {
        enable = true
        filter = "ERRORS_ONLY"
      }
    }
  }
}

# Identity-Aware Proxy
module "iap" {
  source = "../../../modules/security/iap"

  project_id = var.project_id

  tunnel_instances = {
    "secure-tunnel" = {
      network     = module.network_security.network.name
      target_tags = ["iap-tunnel"]
    }
  }

  bindings = {
    "roles/iap.tunnelResourceAccessor" = {
      members = var.iap_members
    }
  }
}

# Private Service Connect
module "private_connect" {
  source = "../../../modules/security/private_connect"

  project_id = var.project_id
  network    = module.network_security.network.name

  service_connections = {
    "secure-connect" = {
      service_attachment = "projects/service-project/regions/us-central1/serviceAttachments/secure-service"
      ip_range          = "10.0.3.0/24"
    }
  }
}

# DDoS Protection
module "ddos_protection" {
  source = "../../../modules/security/cloud_armor"

  project_id = var.project_id

  security_policies = {
    "ddos-policy" = {
      description = "DDoS protection policy"
      type        = "CLOUD_ARMOR_EDGE"
      rules = [
        {
          action      = "rate_based_ban"
          priority    = 1000
          description = "Rate limiting rule"
          expression  = "true"
          rate_limit_options = {
            rate_limit_threshold = {
              count        = 100
              interval_sec = 60
            }
            conform_action = "allow"
            exceed_action  = "deny(429)"
          }
        }
      ]
    }
  }
}

# SSL Policies
module "ssl_policies" {
  source = "../../../modules/security/ssl_policy"

  project_id = var.project_id

  policies = {
    "secure-ssl" = {
      name            = "secure-ssl"
      profile         = "RESTRICTED"
      min_tls_version = "TLS_1_2"
    }
  }
}

# Network Security Monitoring
module "network_monitoring" {
  source = "../../../modules/security/monitoring"

  project_id = var.project_id

  alert_policies = {
    "network-anomaly" = {
      display_name = "Network Anomaly Detection"
      combiner     = "OR"
      conditions = [
        {
          display_name = "High Network Traffic"
          condition_threshold = {
            filter     = "metric.type=\"compute.googleapis.com/instance/network/received_bytes_count\""
            duration   = "300s"
            comparison = "COMPARISON_GT"
            threshold_value = 1000000000  # 1GB
          }
        }
      ]
    }
  }

  notification_channels = var.notification_channels
}

# VPC Flow Logs
module "flow_logs" {
  source = "../../../modules/security/vpc_flow_logs"

  project_id = var.project_id
  network    = module.network_security.network.name

  flow_logs = {
    "network-logs" = {
      enable = true
      aggregation_interval = "INTERVAL_5_SEC"
      flow_sampling = 0.5
      metadata = "INCLUDE_ALL_METADATA"
    }
  }
}
