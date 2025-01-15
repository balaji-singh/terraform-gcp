variable "organization_id" {
  description = "The organization ID"
  type        = string
}

variable "enable_organization_settings" {
  description = "Whether to enable organization settings"
  type        = bool
  default     = true
}

variable "enable_asset_discovery" {
  description = "Whether to enable asset discovery"
  type        = bool
  default     = true
}

variable "asset_discovery_config_mode" {
  description = "The mode for asset discovery configuration"
  type        = string
  default     = "ACTIVE"
}

variable "asset_discovery_config_period" {
  description = "The period for asset discovery configuration"
  type        = string
  default     = "86400s"
}

variable "sources" {
  description = "Map of sources to create"
  type = map(object({
    display_name = string
    description  = string
  }))
  default = {}
}

variable "notification_configs" {
  description = "Map of notification configs to create"
  type = map(object({
    description  = string
    pubsub_topic = string
    filter       = string
  }))
  default = {}
}

variable "findings" {
  description = "Map of findings to create"
  type = map(object({
    source_name      = string
    parent          = string
    resource_name   = string
    state           = string
    category        = string
    event_time      = string
    severity        = string
    security_marks  = optional(map(string))
    source_properties = optional(map(string))
  }))
  default = {}
}

variable "mute_configs" {
  description = "Map of mute configs to create"
  type = map(object({
    parent      = string
    filter      = string
    description = string
  }))
  default = {}
}

variable "source_iam_bindings" {
  description = "Map of source IAM bindings"
  type = map(object({
    source_name = string
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

variable "custom_modules" {
  description = "Map of custom modules to create"
  type = map(object({
    display_name     = string
    custom_config    = string
    enablement_state = string
  }))
  default = {}
}
