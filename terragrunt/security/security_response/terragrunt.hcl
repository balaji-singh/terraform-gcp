include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/security/response"
}

dependency "monitoring" {
  config_path = "../monitoring"
}

inputs = {
  incident_configs = {
    "data-breach" = {
      display_name = "Data Breach Response"
      notification_channels = dependency.monitoring.outputs.notification_channel_ids
      alert_threshold = "HIGH"
    }
    "security-violation" = {
      display_name = "Security Policy Violation"
      notification_channels = dependency.monitoring.outputs.notification_channel_ids
      alert_threshold = "MEDIUM"
    }
  }

  response_policies = {
    "critical-incident" = {
      name = "Critical Security Incident"
      description = "Response plan for critical security incidents"
      steps = [
        "Isolate affected systems",
        "Notify security team",
        "Begin forensic analysis",
        "Implement containment measures",
        "Notify stakeholders"
      ]
      automation_rules = {
        "isolate-system" = {
          condition = "severity == 'CRITICAL'"
          actions = [
            "disable_network_access",
            "create_snapshot",
            "notify_team"
          ]
        }
      }
    }
    "data-exfiltration" = {
      name = "Data Exfiltration Response"
      description = "Response plan for data exfiltration attempts"
      steps = [
        "Block suspicious IPs",
        "Review audit logs",
        "Assess data exposure",
        "Implement additional controls"
      ]
      automation_rules = {
        "block-traffic" = {
          condition = "threat_type == 'DATA_EXFILTRATION'"
          actions = [
            "block_ip_addresses",
            "enable_dlp_controls",
            "notify_data_owner"
          ]
        }
      }
    }
  }

  playbooks = {
    "incident-response" = {
      name = "Security Incident Response"
      description = "Standard playbook for security incidents"
      triggers = ["CRITICAL_ALERT", "COMPLIANCE_VIOLATION"]
      actions = [
        {
          type = "notification"
          params = {
            channels = dependency.monitoring.outputs.notification_channel_ids
            message = "Security incident detected: {{incident.name}}"
          }
        },
        {
          type = "remediation"
          params = {
            function = "projects/${local.project_id}/functions/incident-remediation"
            data = {
              incident_type = "{{incident.type}}"
              severity = "{{incident.severity}}"
            }
          }
        }
      ]
    }
  }

  automation_rules = {
    "auto-remediation" = {
      name = "Automatic Remediation"
      description = "Rules for automatic incident remediation"
      conditions = {
        severity = ["HIGH", "CRITICAL"]
        threat_types = ["MALWARE", "UNAUTHORIZED_ACCESS"]
      }
      actions = [
        "ISOLATE_RESOURCE",
        "NOTIFY_SECURITY_TEAM",
        "CREATE_INCIDENT_TICKET"
      ]
    }
  }
}
