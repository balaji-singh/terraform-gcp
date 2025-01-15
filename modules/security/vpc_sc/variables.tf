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

variable "access_levels" {
  description = "Map of access levels to create"
  type = map(object({
    title = string
    ip_subnetworks = optional(list(string))
    required_access_levels = optional(list(string))
    members = optional(object({
      users            = optional(list(string))
      groups           = optional(list(string))
      service_accounts = optional(list(string))
    }))
    regions = optional(list(string))
    negate  = optional(bool)
    combining_function = optional(string)
  }))
  default = {}
}

variable "service_perimeters" {
  description = "Map of service perimeters to create"
  type = map(object({
    title = string
    restricted_services = list(string)
    access_levels      = list(string)
    vpc_accessible_services = optional(object({
      enable_restriction = bool
      allowed_services  = list(string)
    }))
    resources = optional(list(object({
      type   = string
      values = list(string)
    })))
    ingress_policies = optional(list(object({
      source_access_level = string
      source_resources   = list(string)
      identity_type      = string
      identities         = list(string)
    })))
    ingress_to = optional(object({
      resources    = list(string)
      service_name = string
      method      = string
      permission  = string
    }))
    egress_policies = optional(list(object({
      identity_type = string
      identities    = list(string)
    })))
    egress_to = optional(object({
      resources    = list(string)
      service_name = string
      method      = string
      permission  = string
    }))
    use_explicit_dry_run_spec = optional(bool)
    spec = optional(object({
      restricted_services = list(string)
      access_levels      = list(string)
      resources          = list(string)
      vpc_accessible_services = object({
        enable_restriction = bool
        allowed_services  = list(string)
      })
    }))
  }))
  default = {}
}
