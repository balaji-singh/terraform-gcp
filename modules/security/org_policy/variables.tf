variable "project_id" {
  description = "The ID of the project where resources will be created"
  type        = string
}

variable "organization_id" {
  description = "The organization ID"
  type        = string
}

variable "organization_policies" {
  description = "Map of organization-level policies to create"
  type = map(object({
    name = string
    rules = list(object({
      enforce = bool
      condition = optional(object({
        description = string
        expression  = string
        location    = string
        title       = string
      }))
      values = optional(object({
        allowed_values = optional(list(string))
        denied_values  = optional(list(string))
      }))
    }))
  }))
  default = {}
}

variable "project_policies" {
  description = "Map of project-level organization policies to create"
  type = map(object({
    boolean_policy = optional(object({
      enforced = bool
    }))
    list_policy = optional(object({
      inherit_from_parent = optional(bool)
      suggested_value     = optional(string)
      allow = optional(object({
        values = optional(list(string))
        all    = optional(bool)
      }))
      deny = optional(object({
        values = optional(list(string))
        all    = optional(bool)
      }))
    }))
    restore_policy = optional(object({
      default = bool
    }))
  }))
  default = {}
}

variable "folder_policies" {
  description = "Map of folder-level organization policies to create"
  type = map(object({
    folder = string
    boolean_policy = optional(object({
      enforced = bool
    }))
    list_policy = optional(object({
      inherit_from_parent = optional(bool)
      suggested_value     = optional(string)
      allow = optional(object({
        values = optional(list(string))
        all    = optional(bool)
      }))
      deny = optional(object({
        values = optional(list(string))
        all    = optional(bool)
      }))
    }))
    restore_policy = optional(object({
      default = bool
    }))
  }))
  default = {}
}
