variable "project_id" {
  description = "The project ID where resources will be created"
  type        = string
}

variable "policy_name" {
  description = "Name of the security policy"
  type        = string
}

variable "description" {
  description = "Description of the security policy"
  type        = string
  default     = ""
}

variable "default_rule_action" {
  description = "Action for the default rule"
  type        = string
  default     = "allow"
}

variable "rules" {
  description = "List of rules for the security policy"
  type = list(object({
    action      = string
    priority    = number
    description = string
    versioned_expr = string
    config = optional(object({
      src_ip_ranges = list(string)
    }))
    expr = optional(object({
      expression = string
    }))
    rate_limit_options = optional(object({
      threshold_count        = number
      threshold_interval_sec = number
      conform_action        = string
      exceed_action         = string
      enforce_on_key        = string
      enforce_on_key_name   = string
    }))
    redirect_options = optional(object({
      type   = string
      target = string
    }))
    header_action = optional(object({
      request_headers_to_add = list(object({
        name  = string
        value = string
      }))
    }))
    preview = optional(bool)
  }))
  default = []
}

variable "adaptive_protection_config" {
  description = "Configuration for adaptive protection"
  type = object({
    enable_layer7_ddos = bool
  })
  default = null
}

variable "recaptcha_options_config" {
  description = "Configuration for reCAPTCHA options"
  type = object({
    redirect_site_key = string
  })
  default = null
}

variable "create_edge_policy" {
  description = "Whether to create an edge security policy"
  type        = bool
  default     = false
}

variable "edge_rules" {
  description = "List of rules for the edge security policy"
  type = list(object({
    action      = string
    priority    = number
    description = string
    versioned_expr = string
    config = optional(object({
      src_ip_ranges = list(string)
    }))
  }))
  default = []
}
