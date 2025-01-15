variable "project_id" {
  description = "The ID of the project where the cloud run service will be created"
  type        = string
}

variable "service_name" {
  description = "The name of the cloud run service"
  type        = string
}

variable "location" {
  description = "The location where the service will be created"
  type        = string
}

variable "container_image" {
  description = "The container image to deploy"
  type        = string
}

variable "cpu_limit" {
  description = "The maximum amount of CPU allowed"
  type        = string
  default     = "1000m"
}

variable "memory_limit" {
  description = "The maximum amount of memory allowed"
  type        = string
  default     = "512Mi"
}

variable "cpu_idle" {
  description = "Enable CPU throttling"
  type        = bool
  default     = true
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 8080
}

variable "environment_variables" {
  description = "Environment variables to be passed to the container"
  type        = map(string)
  default     = {}
}

variable "volume_mounts" {
  description = "Volume mounts for the container"
  type = list(object({
    name       = string
    mount_path = string
  }))
  default = []
}

variable "volumes" {
  description = "Volumes to be mounted"
  type = list(object({
    name         = string
    secret_name  = string
    default_mode = number
    path         = string
    version      = string
    mode         = number
  }))
  default = []
}

variable "service_account_email" {
  description = "The service account email to run the service as"
  type        = string
}

variable "timeout_seconds" {
  description = "Maximum duration the instance is allowed for responding to a request"
  type        = number
  default     = 300
}

variable "max_instance_request_concurrency" {
  description = "Maximum number of concurrent requests per instance"
  type        = number
  default     = 80
}

variable "execution_environment" {
  description = "The execution environment for the cloud run service"
  type        = string
  default     = "EXECUTION_ENVIRONMENT_GEN2"
}

variable "ingress" {
  description = "Ingress settings for the service"
  type        = string
  default     = "INGRESS_TRAFFIC_ALL"
}

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 100
}
