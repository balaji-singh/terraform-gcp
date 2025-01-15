variable "organization_id" {
  description = "The organization ID"
  type        = string
}

variable "custom_modules" {
  description = "Map of custom security health analytics modules to create"
  type = map(object({
    description = string
    finding_configs = list(object({
      finding_class_name = string
      severity          = string
      resource_type     = string
      category         = string
      properties       = map(string)
    }))
  }))
  default = {}
}

variable "source_iam_bindings" {
  description = "Map of IAM bindings for security sources"
  type = map(object({
    source  = string
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

variable "notification_configs" {
  description = "Map of notification configurations to create"
  type = map(object({
    description  = string
    pubsub_topic = string
    filter       = string
  }))
  default = {}
}

variable "mute_configs" {
  description = "Map of mute configurations to create"
  type = map(object({
    description = string
    filter      = string
    update_time = optional(object({
      seconds = number
      nanos   = number
    }))
  }))
  default = {}
}

variable "findings" {
  description = "Map of findings to create"
  type = map(object({
    source           = string
    state            = string
    category         = string
    resource_name    = string
    event_time = object({
      seconds = number
      nanos   = number
    })
    severity          = string
    source_properties = map(string)
    security_marks    = optional(map(string))
    external_uri     = optional(string)
  }))
  default = {}
}
