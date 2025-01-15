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

variable "scan_urls" {
  description = "List of URLs to scan"
  type        = list(string)
}

variable "scanner_username" {
  description = "Username for security scanner authentication"
  type        = string
  sensitive   = true
}

variable "scanner_password" {
  description = "Password for security scanner authentication"
  type        = string
  sensitive   = true
}

variable "trusted_image_projects" {
  description = "List of trusted image projects"
  type        = list(string)
  default     = []
}

variable "allowed_ip_ranges" {
  description = "List of allowed IP ranges"
  type        = list(string)
  default     = []
}

variable "audit_retention_days" {
  description = "Number of days to retain audit logs"
  type        = number
  default     = 365
}

variable "encryption_key_rotation_period" {
  description = "Rotation period for encryption keys in seconds"
  type        = number
  default     = 7776000  # 90 days
}

variable "security_contacts" {
  description = "List of security contact email addresses"
  type        = list(string)
  default     = []
}

variable "monitoring_notification_channels" {
  description = "List of monitoring notification channel IDs"
  type        = list(string)
  default     = []
}

variable "required_security_headers" {
  description = "Map of required security headers and their values"
  type        = map(string)
  default     = {
    "Content-Security-Policy" = "default-src 'self'"
    "X-Frame-Options"        = "DENY"
    "X-XSS-Protection"       = "1; mode=block"
    "X-Content-Type-Options" = "nosniff"
  }
}

variable "restricted_services" {
  description = "List of services to restrict in VPC Service Controls"
  type        = list(string)
  default     = [
    "storage.googleapis.com",
    "bigquery.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudkms.googleapis.com"
  ]
}

variable "compliance_standards" {
  description = "Map of compliance standards to enforce"
  type = map(object({
    enabled     = bool
    description = string
    controls    = list(string)
  }))
  default = {
    hipaa = {
      enabled     = true
      description = "HIPAA compliance controls"
      controls    = ["access-control", "audit-logging", "encryption"]
    }
    pci = {
      enabled     = true
      description = "PCI DSS compliance controls"
      controls    = ["network-security", "data-encryption", "access-control"]
    }
  }
}

variable "security_alert_thresholds" {
  description = "Map of security alert thresholds"
  type = map(object({
    metric      = string
    threshold   = number
    duration    = string
    severity    = string
  }))
  default = {
    failed_login_attempts = {
      metric    = "failed_login_count"
      threshold = 5
      duration  = "300s"
      severity  = "CRITICAL"
    }
    network_anomalies = {
      metric    = "network_anomaly_score"
      threshold = 0.8
      duration  = "300s"
      severity  = "HIGH"
    }
  }
}
