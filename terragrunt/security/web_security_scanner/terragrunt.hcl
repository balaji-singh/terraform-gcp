include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/security/security_scanner"
}

dependency "security_center" {
  config_path = "../security_center"
}

inputs = {
  scan_configs = {
    "web-app-scan" = {
      display_name = "Web Application Security Scan"
      starting_urls = ["https://example.com"]
      target_platforms = ["COMPUTE", "APP_ENGINE"]
      schedule = {
        schedule_time = "2024-12-22T00:00:00Z"
        interval = "WEEKLY"
      }
      authentication = {
        google_account = {
          username = "scanner@example.com"
        }
      }
      blacklist_patterns = [
        "*/admin/*",
        "*/internal/*"
      ]
    }
    "api-security-scan" = {
      display_name = "API Security Scan"
      starting_urls = ["https://api.example.com"]
      target_platforms = ["COMPUTE"]
      schedule = {
        schedule_time = "2024-12-22T00:00:00Z"
        interval = "DAILY"
      }
      authentication = {
        custom_account = {
          username = "api-scanner"
          password_secret = "projects/${local.project_id}/secrets/api-scanner-password"
        }
      }
      blacklist_patterns = [
        "*/internal/*",
        "*/backup/*"
      ]
    }
  }

  scan_rules = {
    "vulnerability-scan" = {
      name = "Vulnerability Scan Rules"
      checks = [
        "XSS",
        "SQL_INJECTION",
        "REMOTE_CODE_EXECUTION",
        "SSRF"
      ]
      severity_levels = ["HIGH", "CRITICAL"]
    }
    "compliance-scan" = {
      name = "Compliance Scan Rules"
      checks = [
        "SECURE_HEADERS",
        "CONTENT_SECURITY_POLICY",
        "SECURE_COOKIES"
      ]
      severity_levels = ["MEDIUM", "HIGH"]
    }
  }

  notification_config = {
    findings = {
      pubsub_topic = "projects/${local.project_id}/topics/security-findings"
      filter = "severity = CRITICAL OR category = VULNERABILITY"
    }
    scan_status = {
      pubsub_topic = "projects/${local.project_id}/topics/scan-status"
      filter = "status = FAILED OR status = COMPLETED"
    }
  }

  integration_config = {
    security_center = {
      enabled = true
      finding_category = "WEB_SECURITY"
      auto_create_findings = true
    }
    cloud_armor = {
      enabled = true
      auto_update_rules = true
      rule_priority = 1000
    }
  }
}
