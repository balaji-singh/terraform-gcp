include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../../modules//security/compliance"
}

inputs = {
  compliance_frameworks = {
    "pci-dss" = {
      enabled = true
      version = "3.2.1"
      controls = [
        "encryption",
        "access_control",
        "audit_logging"
      ]
    }
    "hipaa" = {
      enabled = true
      version = "2013"
      controls = [
        "access_control",
        "audit_logging",
        "encryption"
      ]
    }
    "sox" = {
      enabled = true
      version = "2002"
      controls = [
        "change_management",
        "access_control",
        "audit_logging"
      ]
    }
  }

  control_mappings = {
    "encryption" = {
      modules = ["kms", "dlp"]
      policies = ["encryption_at_rest", "encryption_in_transit"]
    }
    "access_control" = {
      modules = ["iam", "vpc_sc"]
      policies = ["least_privilege", "separation_of_duties"]
    }
  }

  monitoring_config = {
    metrics = {
      "compliance_status" = {
        type = "custom.googleapis.com/compliance/status"
        description = "Compliance status metrics"
      }
    }
    alerts = {
      "compliance_violation" = {
        condition = "resource.type=compliance AND status=VIOLATION"
        notification_channels = ["email", "slack"]
      }
    }
  }

  reporting_config = {
    reports = {
      "compliance_report" = {
        schedule = "daily"
        format = "pdf"
        recipients = ["compliance@example.com"]
      }
    }
  }
}
