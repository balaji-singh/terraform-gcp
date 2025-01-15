variable "project_id" {
  description = "The ID of the project where resources will be created"
  type        = string
}

variable "organization_id" {
  description = "The organization ID"
  type        = string
}

variable "project_audit_configs" {
  description = "Map of project-level audit log configurations"
  type = map(object({
    log_configs = list(object({
      log_type         = string
      exempted_members = optional(list(string))
    }))
  }))
  default = {}
}

variable "organization_audit_configs" {
  description = "Map of organization-level audit log configurations"
  type = map(object({
    log_configs = list(object({
      log_type         = string
      exempted_members = optional(list(string))
    }))
  }))
  default = {}
}

variable "folder_audit_configs" {
  description = "Map of folder-level audit log configurations"
  type = map(object({
    folder_id = string
    log_configs = list(object({
      log_type         = string
      exempted_members = optional(list(string))
    }))
  }))
  default = {}
}

variable "project_sinks" {
  description = "Map of logging sinks to create"
  type = map(object({
    destination = string
    filter      = string
    unique_writer_identity = bool
    use_partitioned_tables = optional(bool)
    exclusions = optional(list(object({
      name        = string
      description = string
      filter      = string
      disabled    = bool
    })))
  }))
  default = {}
}

variable "logging_metrics" {
  description = "Map of logging metrics to create"
  type = map(object({
    filter       = string
    description = string
    metric_kind = string
    value_type  = string
    unit        = string
    label_key   = string
    label_value_type = string
    label_description = string
    label_extractors = optional(map(string))
  }))
  default = {}
}

variable "logging_buckets" {
  description = "Map of logging buckets to create"
  type = map(object({
    location       = string
    retention_days = number
    kms_key_name   = optional(string)
  }))
  default = {}
}
