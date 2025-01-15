variable "project_id" {
  description = "The ID of the project where resources will be created"
  type        = string
}

variable "location" {
  description = "The location for the KMS key ring"
  type        = string
}

variable "key_ring_name" {
  description = "The name of the KMS key ring"
  type        = string
}

variable "crypto_keys" {
  description = "Map of crypto keys to create"
  type = map(object({
    rotation_period = string
    labels         = map(string)
    purpose        = string
    version_template = object({
      algorithm        = string
      protection_level = string
    })
    import_only = optional(object({
      rsa_aes_wrapped_key = string
    }))
    destroy_scheduled_duration    = optional(string)
    skip_initial_version_creation = optional(bool)
  }))
  default = {}
}

variable "crypto_key_iam_bindings" {
  description = "Map of crypto key IAM bindings"
  type = map(object({
    crypto_key_name = string
    role           = string
    members        = list(string)
    condition = optional(object({
      title       = string
      description = string
      expression  = string
    }))
  }))
  default = {}
}

variable "key_ring_iam_bindings" {
  description = "Map of key ring IAM bindings"
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

variable "import_jobs" {
  description = "Map of import jobs to create"
  type = map(object({
    import_method    = string
    protection_level = string
    expires_at      = string
  }))
  default = {}
}
