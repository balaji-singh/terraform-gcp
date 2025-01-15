provider "google" {
  project = var.project_id
  region  = var.region
}

module "cloud_armor" {
  source = "../../../modules/security/armor"

  project_id   = var.project_id
  policy_name  = "example-policy"
  description  = "Example Cloud Armor security policy"

  default_rule_action = "allow"

  # Standard rules
  rules = [
    {
      action      = "deny(403)"
      priority    = 1000
      description = "Block specified IP ranges"
      versioned_expr = "SRC_IPS_V1"
      config = {
        src_ip_ranges = ["192.0.2.0/24", "198.51.100.0/24"]
      }
      preview = false
    },
    {
      action      = "rate_based_ban"
      priority    = 2000
      description = "Rate limit by IP"
      versioned_expr = "SRC_IPS_V1"
      config = {
        src_ip_ranges = ["*"]
      }
      rate_limit_options = {
        threshold_count        = 100
        threshold_interval_sec = 60
        conform_action        = "allow"
        exceed_action         = "deny(429)"
        enforce_on_key        = "IP"
        enforce_on_key_name   = "client-ip"
      }
      preview = false
    },
    {
      action      = "deny(403)"
      priority    = 3000
      description = "Block SQL injection"
      versioned_expr = "SECURITY_RULES"
      expr = {
        expression = "evaluatePreconfiguredExpr('sqli-stable')"
      }
      preview = false
    },
    {
      action      = "deny(403)"
      priority    = 4000
      description = "Block XSS attacks"
      versioned_expr = "SECURITY_RULES"
      expr = {
        expression = "evaluatePreconfiguredExpr('xss-stable')"
      }
      preview = false
    }
  ]

  # Adaptive protection configuration
  adaptive_protection_config = {
    enable_layer7_ddos = true
  }

  # reCAPTCHA configuration
  recaptcha_options_config = {
    redirect_site_key = "6LdFOKIeAAAAAJKwN"
  }

  # Edge security policy
  create_edge_policy = true
  edge_rules = [
    {
      action      = "deny(403)"
      priority    = 1000
      description = "Block specific countries"
      versioned_expr = "SRC_IPS_V1"
      config = {
        src_ip_ranges = ["192.0.2.0/24"]  # Replace with actual country IP ranges
      }
    },
    {
      action      = "rate_based_ban"
      priority    = 2000
      description = "DDoS protection at edge"
      versioned_expr = "SRC_IPS_V1"
      config = {
        src_ip_ranges = ["*"]
      }
    }
  ]
}
