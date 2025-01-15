variable "project_id" {
  description = "The ID of the project to create the bucket in"
  type        = string
}

variable "name" {
  description = "The name of the bucket"
  type        = string
}

variable "location" {
  description = "The location of the bucket"
  type        = string
}

variable "storage_class" {
  description = "The Storage Class of the new bucket"
  type        = string
  default     = "STANDARD"
}

variable "uniform_bucket_level_access" {
  description = "Enables Uniform bucket-level access to a bucket"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "When deleting a bucket, this boolean option will delete all contained objects"
  type        = bool
  default     = false
}

variable "versioning" {
  description = "While set to true, versioning is fully enabled for this bucket"
  type        = bool
  default     = false
}

variable "lifecycle_rules" {
  description = "The bucket's Lifecycle Rules configuration"
  type = list(object({
    # Object with keys:
    # - type - The type of the action of this Lifecycle Rule
    # - storage_class - (Required if action type is SetStorageClass) The target Storage Class of objects affected by this Lifecycle Rule
    action = any

    # Object with keys:
    # - age - (Optional) Minimum age of an object in days to satisfy this condition
    # - created_before - (Optional) Creation date of an object in RFC 3339 format to satisfy this condition
    # - with_state - (Optional) Match to live and/or archived objects. Supported values include: "LIVE", "ARCHIVED", "ANY"
    # - matches_storage_class - (Optional) Storage Class of objects to satisfy this condition. Supported values include: MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, STANDARD, DURABLE_REDUCED_AVAILABILITY
    # - num_newer_versions - (Optional) Relevant only for versioned objects
    condition = any
  }))
  default = []
}

variable "encryption" {
  description = "A Cloud KMS key that will be used to encrypt objects inserted into this bucket"
  type        = string
  default     = null
}

variable "cors" {
  description = "The bucket's Cross-Origin Resource Sharing (CORS) configuration"
  type = list(object({
    origin          = list(string)
    method          = list(string)
    response_header = list(string)
    max_age_seconds = number
  }))
  default = []
}

variable "labels" {
  description = "A map of key/value label pairs to assign to the bucket"
  type        = map(string)
  default     = {}
}
