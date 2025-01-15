include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/security/cloud_armor"
}

dependency "network" {
  config_path = "../network"
}

inputs = {
  security_policies = {
    "waf-policy" = {
      description = "WAF security policy"
      type = "CLOUD_ARMOR"
      rules = [
        {
          action = "deny(403)"
          priority = 1000
          description = "Block SQL injection"
          expression = "evaluatePreconfiguredExpr('sqli-stable')"
        },
        {
          action = "deny(403)"
          priority = 1001
          description = "Block XSS"
          expression = "evaluatePreconfiguredExpr('xss-stable')"
        }
      ]
      adaptive_protection_config = {
        layer_7_ddos_defense_config = {
          enable = true
          rule_visibility = "STANDARD"
        }
      }
    }
  }
}
