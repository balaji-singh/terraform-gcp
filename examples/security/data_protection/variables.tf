variable "project_id" {
  description = "The ID of the project where resources will be created"
  type        = string
}

variable "organization_id" {
  description = "The organization ID"
  type        = string
}

variable "region" {
  description = "The region where resources will be created"
  type        = string
  default     = "us-central1"
}

variable "access_policy_id" {
  description = "The ID of the access policy"
  type        = string
}

variable "data_access_members" {
  description = "List of members with data access permissions"
  type        = list(string)
  default     = []
}

variable "encryption_config" {
  description = "Configuration for data encryption"
  type = object({
    key_rotation_period = string
    protection_level    = string
    key_algorithm      = string
  })
  default = {
    key_rotation_period = "7776000s"  # 90 days
    protection_level    = "HSM"
    key_algorithm      = "GOOGLE_SYMMETRIC_ENCRYPTION"
  }
}

variable "dlp_config" {
  description = "Configuration for DLP"
  type = object({
    info_types = list(string)
    min_likelihood = string
    max_findings_per_item = number
    max_findings_per_request = number
  })
  default = {
    info_types = [
      "CREDIT_CARD_NUMBER",
      "EMAIL_ADDRESS",
      "PHONE_NUMBER",
      "US_SOCIAL_SECURITY_NUMBER"
    ]
    min_likelihood = "LIKELY"
    max_findings_per_item = 100
    max_findings_per_request = 1000
  }
}

variable "vpc_sc_config" {
  description = "Configuration for VPC Service Controls"
  type = object({
    restricted_services = list(string)
    access_levels = list(string)
  })
  default = {
    restricted_services = [
      "storage.googleapis.com",
      "bigquery.googleapis.com",
      "dataflow.googleapis.com"
    ]
    access_levels = []
  }
}

variable "audit_config" {
  description = "Configuration for audit logging"
  type = object({
    log_types = list(string)
    retention_days = number
  })
  default = {
    log_types = ["DATA_READ", "DATA_WRITE"]
    retention_days = 365
  }
}

variable "security_alert_config" {
  description = "Configuration for security alerts"
  type = object({
    alert_filter = string
    notification_channels = list(string)
  })
  default = {
    alert_filter = "category = \"DATA_LOSS\" OR category = \"UNAUTHORIZED_ACCESS\""
    notification_channels = []
  }
}

variable "data_classification" {
  description = "Data classification levels and their requirements"
  type = map(object({
    encryption_required = bool
    audit_required = bool
    dlp_required = bool
    vpc_sc_required = bool
    access_approval_required = bool
  }))
  default = {
    public = {
      encryption_required = false
      audit_required = true
      dlp_required = false
      vpc_sc_required = false
      access_approval_required = false
    }
    internal = {
      encryption_required = true
      audit_required = true
      dlp_required = true
      vpc_sc_required = false
      access_approval_required = false
    }
    confidential = {
      encryption_required = true
      audit_required = true
      dlp_required = true
      vpc_sc_required = true
      access_approval_required = true
    }
  }
}

variable "compliance_requirements" {
  description = "Compliance requirements for data protection"
  type = map(object({
    enabled = bool
    controls = list(string)
  }))
  default = {
    hipaa = {
      enabled = true
      controls = [
        "encryption",
        "access_control",
        "audit_logging"
      ]
    }
    pci = {
      enabled = true
      controls = [
        "encryption",
        "access_control",
        "audit_logging",
        "data_discovery"
      ]
    }
  }
}

variable "backup_config" {
  description = "Configuration for data backup"
  type = object({
    enabled = bool
    retention_days = number
    encryption_required = bool
  })
  default = {
    enabled = true
    retention_days = 30
    encryption_required = true
  }
}
