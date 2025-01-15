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

variable "environment" {
  description = "The environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "repository_name" {
  description = "Name of the source code repository"
  type        = string
}

variable "branch_name" {
  description = "Branch name to trigger builds"
  type        = string
  default     = "main"
}

variable "build_timeout" {
  description = "Build timeout duration"
  type        = string
  default     = "1800s"
}

variable "security_scan_config" {
  description = "Security scanning configuration"
  type = object({
    enabled = bool
    scan_on_push = bool
    scan_frequency = string
    vulnerability_threshold = string
  })
  default = {
    enabled = true
    scan_on_push = true
    scan_frequency = "EVERY_PUSH"
    vulnerability_threshold = "HIGH"
  }
}

variable "container_analysis_config" {
  description = "Container analysis configuration"
  type = object({
    enabled = bool
    scan_frequency = string
    vulnerability_threshold = string
  })
  default = {
    enabled = true
    scan_frequency = "DAILY"
    vulnerability_threshold = "HIGH"
  }
}

variable "attestation_config" {
  description = "Binary authorization attestation configuration"
  type = object({
    required = bool
    attestor_name = string
    attestor_email = string
  })
  default = {
    required = true
    attestor_name = "security-attestor"
    attestor_email = "security-team@example.com"
  }
}

variable "secret_rotation_config" {
  description = "Secret rotation configuration"
  type = object({
    enabled = bool
    rotation_period = string
    next_rotation_time = string
  })
  default = {
    enabled = true
    rotation_period = "720h"
    next_rotation_time = "2024-12-31T00:00:00Z"
  }
}

variable "pipeline_service_account_roles" {
  description = "List of roles to assign to pipeline service account"
  type        = list(string)
  default     = [
    "roles/cloudbuild.builds.builder",
    "roles/containeranalysis.notes.attacher",
    "roles/containeranalysis.occurrences.viewer",
    "roles/secretmanager.secretAccessor"
  ]
}

variable "audit_log_retention" {
  description = "Audit log retention period in days"
  type        = number
  default     = 30
}

variable "notification_channels" {
  description = "List of notification channels for security alerts"
  type        = list(string)
  default     = []
}

variable "security_controls" {
  description = "Security controls configuration"
  type = object({
    require_vulnerability_scanning = bool
    require_attestation = bool
    require_security_reviews = bool
    block_on_high_severity = bool
  })
  default = {
    require_vulnerability_scanning = true
    require_attestation = true
    require_security_reviews = true
    block_on_high_severity = true
  }
}

variable "compliance_standards" {
  description = "List of compliance standards to enforce"
  type        = list(string)
  default     = ["SOC2", "ISO27001"]
}

variable "allowed_base_images" {
  description = "List of allowed base images"
  type        = list(string)
  default     = [
    "gcr.io/distroless/static",
    "gcr.io/distroless/base"
  ]
}

variable "required_security_headers" {
  description = "Required security headers for applications"
  type        = map(string)
  default     = {
    "Content-Security-Policy" = "default-src 'self'"
    "X-Frame-Options"        = "DENY"
    "X-Content-Type-Options" = "nosniff"
  }
}
