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

variable "labels" {
  description = "A map of labels to apply to resources"
  type        = map(string)
  default     = {
    environment = "dev"
    managed_by  = "terraform"
  }
}

variable "network_name" {
  description = "The name of the network to use"
  type        = string
  default     = "default"
}

variable "subnet_name" {
  description = "The name of the subnet to use"
  type        = string
  default     = "default"
}

variable "service_account_id" {
  description = "The ID of the service account to use"
  type        = string
  default     = "terraform-sa"
}

variable "kms_key_ring" {
  description = "The name of the KMS key ring"
  type        = string
  default     = "terraform-keyring"
}

variable "kms_crypto_key" {
  description = "The name of the KMS crypto key"
  type        = string
  default     = "terraform-key"
}

variable "notification_channels" {
  description = "List of notification channel IDs"
  type        = list(string)
  default     = []
}

variable "alert_policies" {
  description = "Map of alert policy configurations"
  type = map(object({
    display_name = string
    combiner     = string
    conditions   = list(map(string))
    enabled      = bool
  }))
  default = {}
}

variable "audit_log_config" {
  description = "Audit log configuration"
  type = object({
    service = string
    audit_log_configs = object({
      log_type         = string
      exempted_members = list(string)
    })
  })
  default = {
    service = "allServices"
    audit_log_configs = {
      log_type         = "DATA_WRITE"
      exempted_members = []
    }
  }
}

variable "security_policies" {
  description = "Map of security policy configurations"
  type = map(object({
    name        = string
    description = string
    rules       = list(map(string))
  }))
  default = {}
}

variable "security_sources" {
  description = "Map of security source configurations"
  type = map(object({
    display_name = string
    description  = string
  }))
  default = {}
}

variable "security_findings" {
  description = "Map of security finding configurations"
  type = map(object({
    source      = string
    category    = string
    severity    = string
    description = string
  }))
  default = {}
}
