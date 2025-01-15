variable "project_id" {
  description = "The ID of the project where resources will be created"
  type        = string
}

variable "scan_configs" {
  description = "Map of scan configurations to create"
  type = map(object({
    starting_urls = list(string)
    target_platforms = list(string)
    google_account = optional(object({
      username = string
      password = string
    }))
    custom_account = optional(object({
      username = string
      password = string
      login_url = string
    }))
    schedule_time = optional(string)
    schedule_interval = optional(string)
    user_agent = optional(string)
    blacklist_patterns = optional(list(string))
    max_qps = optional(number)
    export_to_security_command_center = optional(object({
      enable = bool
      filter = string
    }))
    risk_level = optional(string)
    managed_scan = optional(bool)
  }))
  default = {}
}

variable "scan_runs" {
  description = "Map of scan runs to create"
  type = map(object({
    scan_config = string
    execution_state = string
  }))
  default = {}
}

variable "scan_config_iam_bindings" {
  description = "Map of IAM bindings for scan configurations"
  type = map(object({
    scan_config = string
    role        = string
    members     = list(string)
    condition = optional(object({
      title       = string
      description = string
      expression  = string
    }))
  }))
  default = {}
}
