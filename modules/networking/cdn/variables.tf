variable "project_id" {
  description = "The project ID to deploy to"
  type        = string
}

variable "name" {
  description = "Name of the CDN backend bucket and associated resources"
  type        = string
}

variable "description" {
  description = "An optional description of this resource"
  type        = string
  default     = ""
}

variable "bucket_name" {
  description = "Name of the storage bucket to be used for CDN content"
  type        = string
}

variable "bucket_location" {
  description = "The GCS location for the bucket"
  type        = string
  default     = "US"
}

variable "storage_class" {
  description = "The Storage Class of the new bucket"
  type        = string
  default     = "STANDARD"
}

variable "force_destroy" {
  description = "When deleting a bucket, this boolean option will delete all contained objects"
  type        = bool
  default     = false
}

variable "cache_mode" {
  description = "The cache mode for the CDN policy"
  type        = string
  default     = "CACHE_ALL_STATIC"
}

variable "client_ttl" {
  description = "Specifies the maximum allowed TTL for cached content served by this origin"
  type        = number
  default     = 3600
}

variable "default_ttl" {
  description = "Specifies the default TTL for cached content served by this origin"
  type        = number
  default     = 3600
}

variable "max_ttl" {
  description = "Specifies the maximum allowed TTL for cached content served by this origin"
  type        = number
  default     = 86400
}

variable "negative_caching" {
  description = "Enables negative caching"
  type        = bool
  default     = false
}

variable "serve_while_stale" {
  description = "Serve existing content from the cache (if available) when revalidating content with the origin"
  type        = number
  default     = 86400
}

variable "signed_url_cache_max_age_sec" {
  description = "Maximum number of seconds the response to a signed URL request will be considered fresh"
  type        = number
  default     = 7200
}

variable "negative_caching_policies" {
  description = "List of negative caching policy configurations"
  type = list(object({
    code = number
    ttl  = number
  }))
  default = []
}

variable "cache_key_policy" {
  description = "Cache key policy configuration"
  type = object({
    include_host           = bool
    include_protocol       = bool
    include_query_string   = bool
    query_string_whitelist = list(string)
    query_string_blacklist = list(string)
  })
  default = null
}

variable "custom_response_headers" {
  description = "Headers that the CDN will set on all responses"
  type        = list(string)
  default     = []
}

variable "cors_origins" {
  description = "List of Origins eligible to receive CORS response headers"
  type        = list(string)
  default     = ["*"]
}

variable "cors_methods" {
  description = "List of HTTP methods eligible for CORS requests"
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "cors_response_headers" {
  description = "List of HTTP headers that can be included in CORS requests"
  type        = list(string)
  default     = ["*"]
}

variable "cors_max_age_seconds" {
  description = "Max age for CORS options requests"
  type        = number
  default     = 3600
}

variable "enable_versioning" {
  description = "Enable versioning for the bucket"
  type        = bool
  default     = false
}

variable "object_age_days" {
  description = "Age in days after which objects should be deleted"
  type        = number
  default     = 30
}

variable "host_rules" {
  description = "List of host rules for the CDN"
  type = list(object({
    hosts        = list(string)
    path_matcher = string
  }))
  default = []
}

variable "path_rules" {
  description = "Map of path rules for the CDN"
  type = map(list(object({
    paths = list(string)
  })))
  default = {}
}

variable "create_ip" {
  description = "Whether to create a new IP address for the CDN"
  type        = bool
  default     = true
}

variable "ip_address" {
  description = "Existing IP address to use (if create_ip is false)"
  type        = string
  default     = null
}
