variable "organization_id" {
  description = "The organization ID"
  type        = string
}

variable "create_access_policy" {
  description = "Whether to create a new access policy"
  type        = bool
  default     = true
}

variable "existing_policy_id" {
  description = "Existing access policy ID if not creating a new one"
  type        = string
  default     = null
}

variable "policy_title" {
  description = "Title of the access policy"
  type        = string
  default     = "Default Policy"
}

variable "policy_scopes" {
  description = "List of scopes for the access policy"
  type        = list(string)
  default     = []
}

variable "custom_access_levels" {
  description = "Map of custom access levels to create"
  type = map(object({
    title = string
    basic = optional(object({
      conditions = list(object({
        os_constraints = optional(list(object({
          os_type                    = string
          minimum_version           = optional(string)
          require_verified_chrome_os = optional(bool)
        })))
        require_screen_lock              = optional(bool)
        allowed_encryption_statuses      = optional(list(string))
        allowed_device_management_levels = optional(list(string))
        require_admin_approval          = optional(bool)
        require_corp_owned              = optional(bool)
        ip_subnetworks                  = optional(list(string))
        required_access_levels          = optional(list(string))
        members                         = optional(list(string))
        negate                          = optional(bool)
        regions                         = optional(list(string))
      }))
      combining_function = string
    }))
    custom = optional(object({
      expression = string
      title      = string
      location   = optional(string)
    }))
  }))
  default = {}
}

variable "gcp_user_access_bindings" {
  description = "Map of GCP user access bindings to create"
  type = map(object({
    group_key     = string
    access_levels = list(string)
  }))
  default = {}
}

variable "service_perimeter_bridges" {
  description = "Map of service perimeter bridges to create"
  type = map(object({
    perimeter_name = string
    resource      = string
  }))
  default = {}
}

variable "access_policy_iam_bindings" {
  description = "Map of IAM bindings for access policy"
  type = map(object({
    role    = string
    members = list(string)
    condition = optional(object({
      title       = string
      description = string
      expression  = string
    }))
  }))
  default = {}
}
