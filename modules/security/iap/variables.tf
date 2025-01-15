variable "project_id" {
  description = "The ID of the project where resources will be created"
  type        = string
}

variable "create_brand" {
  description = "Whether to create a new OAuth brand"
  type        = bool
  default     = true
}

variable "existing_brand_id" {
  description = "Existing OAuth brand ID if not creating a new one"
  type        = string
  default     = null
}

variable "support_email" {
  description = "Support email for the OAuth brand"
  type        = string
}

variable "application_title" {
  description = "Application title for the OAuth brand"
  type        = string
}

variable "oauth_clients" {
  description = "Map of OAuth clients to create"
  type = map(object({
    display_name = string
  }))
  default = {}
}

variable "backend_service_iam_bindings" {
  description = "Map of IAM bindings for backend services"
  type = map(object({
    backend_service = string
    role           = string
    members        = list(string)
  }))
  default = {}
}

variable "web_iam_bindings" {
  description = "Map of IAM bindings for IAP web"
  type = map(object({
    role    = string
    members = list(string)
  }))
  default = {}
}

variable "app_engine_iam_bindings" {
  description = "Map of IAM bindings for App Engine"
  type = map(object({
    app_id  = string
    role    = string
    members = list(string)
  }))
  default = {}
}

variable "compute_iam_bindings" {
  description = "Map of IAM bindings for Compute Engine"
  type = map(object({
    role    = string
    members = list(string)
  }))
  default = {}
}

variable "tunnel_instance_iam_bindings" {
  description = "Map of IAM bindings for tunnel instances"
  type = map(object({
    zone     = string
    instance = string
    role     = string
    members  = list(string)
  }))
  default = {}
}

variable "create_iap_policy" {
  description = "Whether to create an IAP policy"
  type        = bool
  default     = false
}

variable "iap_policy_data" {
  description = "IAP policy data if creating a policy"
  type        = string
  default     = null
}

variable "backend_service_configs" {
  description = "Map of backend service configurations"
  type = map(object({
    backend_service = string
    oauth2_client_id = optional(object({
      client_id     = string
      client_secret = string
    }))
  }))
  default = {}
}
