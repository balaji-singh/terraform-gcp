variable "project_id" {
  description = "The ID of the project where resources will be created"
  type        = string
}

variable "labels" {
  description = "Labels to apply to all secrets"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Map of secrets to create"
  type = map(object({
    labels = optional(map(string), {})
    replication = object({
      automatic = optional(object({
        customer_managed_encryption = optional(object({
          kms_key_name = string
        }))
      }))
      user_managed = optional(object({
        replicas = list(object({
          location = string
          customer_managed_encryption = optional(object({
            kms_key_name = string
          }))
        }))
      }))
    })
    rotation = optional(object({
      rotation_period = string
    }))
    next_rotation_time = optional(string)
    topics = optional(list(object({
      name = string
    })))
    expire_time = optional(string)
    versions = list(object({
      version     = string
      secret_data = string
      enabled     = bool
    }))
  }))
  description = "Map of secrets to manage"
}

variable "iam_bindings" {
  description = "Map of IAM bindings for secrets"
  type = map(object({
    secret_id = string
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
