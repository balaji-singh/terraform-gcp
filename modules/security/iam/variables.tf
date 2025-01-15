variable "project_id" {
  description = "The ID of the project where resources will be created"
  type        = string
}

variable "project_roles" {
  description = "Map of roles to list of members to grant the role to"
  type        = map(list(string))
  default     = {}
}

variable "project_role_conditions" {
  description = "Map of roles to conditions for conditional role bindings"
  type = map(object({
    title       = string
    description = string
    expression  = string
  }))
  default = {}
}

variable "service_accounts" {
  description = "Map of service accounts to create"
  type = map(object({
    display_name = string
    description  = string
    keys = optional(list(object({
      key_id          = string
      key_algorithm   = optional(string)
      public_key_type = optional(string)
    })))
  }))
  default = {}
}

variable "custom_roles" {
  description = "Map of custom roles to create"
  type = map(object({
    title       = string
    description = string
    permissions = list(string)
    stage       = string
  }))
  default = {}
}

variable "service_account_bindings" {
  description = "Map of service account IAM bindings"
  type = map(object({
    service_account_id = string
    role              = string
    members           = list(string)
    condition = optional(object({
      title       = string
      description = string
      expression  = string
    }))
  }))
  default = {}
}

variable "workload_identity_pools" {
  description = "Map of workload identity pools to create"
  type = map(object({
    display_name = string
    description  = string
    disabled     = bool
  }))
  default = {}
}

variable "workload_identity_pool_providers" {
  description = "Map of workload identity pool providers to create"
  type = map(object({
    pool_id             = string
    display_name        = string
    description         = string
    disabled            = bool
    attribute_mapping   = map(string)
    attribute_condition = string
    oidc_config = object({
      allowed_audiences = list(string)
      issuer_uri       = string
    })
  }))
  default = {}
}
