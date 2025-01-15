variable "project_id" {
  description = "The ID of the project where resources will be created"
  type        = string
}

variable "global_policy_evaluation_mode" {
  description = "Global policy evaluation mode"
  type        = string
  default     = "ENABLE"
}

variable "description" {
  description = "Description of the binary authorization policy"
  type        = string
  default     = ""
}

variable "default_admission_rule" {
  description = "Default admission rule for the policy"
  type = object({
    evaluation_mode         = string
    enforcement_mode        = string
    require_attestations_by = list(string)
  })
}

variable "cluster_admission_rules" {
  description = "Map of cluster-specific admission rules"
  type = map(object({
    evaluation_mode         = string
    enforcement_mode        = string
    require_attestations_by = list(string)
  }))
  default = {}
}

variable "admission_whitelist_patterns" {
  description = "List of admission whitelist patterns"
  type        = list(string)
  default     = []
}

variable "attestors" {
  description = "Map of attestors to create"
  type = map(object({
    description    = string
    note_reference = string
    public_keys = list(object({
      public_key_pem       = string
      signature_algorithm = string
    }))
    ascii_armored_pgp_public_keys = list(string)
    key_id  = string
    comment = string
  }))
  default = {}
}

variable "attestor_iam_bindings" {
  description = "Map of IAM bindings for attestors"
  type = map(object({
    attestor_name = string
    role          = string
    members       = list(string)
    condition = optional(object({
      title       = string
      description = string
      expression  = string
    }))
  }))
  default = {}
}
