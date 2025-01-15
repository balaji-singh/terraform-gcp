variable "project_id" {
  description = "The project ID to deploy to"
  type        = string
}

variable "name" {
  description = "Name for the load balancer and associated resources"
  type        = string
}

variable "create_address" {
  description = "Create a new global address"
  type        = bool
  default     = true
}

variable "address" {
  description = "Existing IP address to use (the actual IP address value)"
  type        = string
  default     = null
}

variable "load_balancing_scheme" {
  description = "Load balancing scheme type (EXTERNAL or INTERNAL)"
  type        = string
  default     = "EXTERNAL"
}

variable "backend_protocol" {
  description = "The protocol used to talk to the backend service"
  type        = string
  default     = "HTTP"
}

variable "backend_port_name" {
  description = "Name of backend port. The same name should appear in the instance groups referenced by this service"
  type        = string
  default     = "http"
}

variable "backend_timeout_sec" {
  description = "How many seconds to wait for the backend before considering it a failed request"
  type        = number
  default     = 30
}

variable "enable_cdn" {
  description = "Enable Cloud CDN for the backend service"
  type        = bool
  default     = false
}

variable "cdn_cache_mode" {
  description = "The cache mode of the CDN policy"
  type        = string
  default     = "CACHE_ALL_STATIC"
}

variable "cdn_client_ttl" {
  description = "Specifies the maximum allowed TTL for cached content served by this origin"
  type        = number
  default     = 3600
}

variable "cdn_default_ttl" {
  description = "Specifies the default TTL for cached content served by this origin"
  type        = number
  default     = 3600
}

variable "cdn_max_ttl" {
  description = "Specifies the maximum allowed TTL for cached content served by this origin"
  type        = number
  default     = 86400
}

variable "cdn_negative_caching" {
  description = "Negative caching allows per-status code TTLs to be set, in order to apply fine-grained caching for common errors or redirects"
  type        = bool
  default     = false
}

variable "cdn_serve_while_stale" {
  description = "Serve existing content from the cache (if available) when revalidating content with the origin"
  type        = number
  default     = 86400
}

variable "backend_groups" {
  description = "List of backend groups"
  type = list(object({
    group           = string
    balancing_mode  = string
    capacity_scaler = number
  }))
}

variable "additional_backend_services" {
  description = "Additional backend services configuration"
  type = map(object({
    protocol     = string
    port_name    = string
    timeout_sec  = number
    enable_cdn   = bool
    backend_groups = list(object({
      group           = string
      balancing_mode  = string
      capacity_scaler = number
    }))
  }))
  default = {}
}

variable "host_rules" {
  description = "List of host rules"
  type = list(object({
    hosts        = list(string)
    path_matcher = string
  }))
  default = []
}

variable "path_rules" {
  description = "Map of path rules"
  type = map(list(object({
    paths   = list(string)
    service = string
  })))
  default = {}
}

variable "health_check_interval_sec" {
  description = "How often to perform a health check"
  type        = number
  default     = 5
}

variable "health_check_timeout_sec" {
  description = "How long to wait before declaring a health check timeout"
  type        = number
  default     = 5
}

variable "health_check_port" {
  description = "Port to perform health checks on"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Path to perform health checks on"
  type        = string
  default     = "/"
}
