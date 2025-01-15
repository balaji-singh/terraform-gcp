variable "project_id" {
  description = "The ID of the project where resources will be created"
  type        = string
}

variable "organization_id" {
  description = "The organization ID"
  type        = string
}

variable "billing_project" {
  description = "The project that will be charged for Cloud Asset API calls"
  type        = string
}

variable "organization_feeds" {
  description = "Map of organization-level asset feeds to create"
  type = map(object({
    content_type = string
    pubsub_destination = object({
      topic = string
    })
    asset_types = list(string)
    condition = object({
      expression  = string
      title       = string
      description = string
    })
  }))
  default = {}
}

variable "folder_feeds" {
  description = "Map of folder-level asset feeds to create"
  type = map(object({
    folder       = string
    content_type = string
    pubsub_destination = object({
      topic = string
    })
    asset_types = list(string)
    condition = object({
      expression  = string
      title       = string
      description = string
    })
  }))
  default = {}
}

variable "project_feeds" {
  description = "Map of project-level asset feeds to create"
  type = map(object({
    content_type = string
    pubsub_destination = object({
      topic = string
    })
    asset_types = list(string)
    condition = object({
      expression  = string
      title       = string
      description = string
    })
  }))
  default = {}
}

variable "organization_saved_queries" {
  description = "Map of organization-level saved queries to create"
  type = map(object({
    description = string
    content = object({
      permissions         = list(string)
      roles              = list(string)
      access_time        = string
      identity           = string
      full_resource_name = string
    })
  }))
  default = {}
}

variable "project_saved_queries" {
  description = "Map of project-level saved queries to create"
  type = map(object({
    description = string
    content = object({
      permissions         = list(string)
      roles              = list(string)
      access_time        = string
      identity           = string
      full_resource_name = string
    })
  }))
  default = {}
}

variable "feed_iam_bindings" {
  description = "Map of IAM bindings for asset feeds"
  type = map(object({
    feed_name = string
    role      = string
    members   = list(string)
    condition = optional(object({
      title       = string
      description = string
      expression  = string
    }))
  }))
  default = {}
}
