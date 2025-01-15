variable "project_id" {
  description = "The ID of the project where the cloud function will be created"
  type        = string
}

variable "function_name" {
  description = "The name of the cloud function"
  type        = string
}

variable "description" {
  description = "Description of the function"
  type        = string
  default     = ""
}

variable "region" {
  description = "The region where the function will be created"
  type        = string
}

variable "runtime" {
  description = "The runtime in which to run the function"
  type        = string
  default     = "python39"
}

variable "entry_point" {
  description = "The name of the function (as defined in source code) to be executed"
  type        = string
}

variable "source_dir" {
  description = "The directory containing the source code"
  type        = string
}

variable "archive_path" {
  description = "Path to the archive file containing the source code"
  type        = string
}

variable "create_bucket" {
  description = "Whether to create a new bucket for the function source"
  type        = bool
  default     = true
}

variable "bucket_name" {
  description = "Name of the existing bucket to use (if create_bucket is false)"
  type        = string
  default     = ""
}

variable "max_instance_count" {
  description = "The maximum number of instances for the function"
  type        = number
  default     = 100
}

variable "min_instance_count" {
  description = "The minimum number of instances for the function"
  type        = number
  default     = 0
}

variable "available_memory" {
  description = "The amount of memory available for the function"
  type        = string
  default     = "256M"
}

variable "timeout_seconds" {
  description = "The function execution timeout"
  type        = number
  default     = 60
}

variable "environment_variables" {
  description = "Environment variables to be passed to the function"
  type        = map(string)
  default     = {}
}

variable "secret_environment_variables" {
  description = "Secret environment variables configuration"
  type = list(object({
    key        = string
    project_id = string
    secret     = string
    version    = string
  }))
  default = []
}

variable "ingress_settings" {
  description = "The ingress settings for the function"
  type        = string
  default     = "ALLOW_ALL"
}

variable "service_account_email" {
  description = "The service account email to be used by the function"
  type        = string
  default     = ""
}

variable "event_type" {
  description = "The type of event to trigger the function"
  type        = string
}

variable "retry_policy" {
  description = "Retry policy for the function"
  type        = string
  default     = "RETRY_POLICY_DO_NOT_RETRY"
}

variable "trigger_service_account_email" {
  description = "Service account email for the trigger"
  type        = string
  default     = ""
}

variable "event_filters" {
  description = "Event filters for the function trigger"
  type = list(object({
    attribute = string
    value     = string
  }))
  default = []
}

variable "labels" {
  description = "Labels to apply to the function"
  type        = map(string)
  default     = {}
}
