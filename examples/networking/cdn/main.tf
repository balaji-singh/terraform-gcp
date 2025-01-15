provider "google" {
  project = var.project_id
  region  = var.region
}

module "cdn" {
  source = "../../../modules/networking/cdn"

  project_id   = var.project_id
  name         = "example-cdn"
  description  = "Example CDN configuration"
  bucket_name  = "example-cdn-bucket"
  
  bucket_location = "US"
  storage_class   = "STANDARD"
  
  # CDN Configuration
  cache_mode = "CACHE_ALL_STATIC"
  client_ttl = 3600
  default_ttl = 3600
  max_ttl     = 86400
  
  negative_caching = true
  serve_while_stale = 86400
  
  negative_caching_policies = [
    {
      code = 404
      ttl  = 300
    },
    {
      code = 502
      ttl  = 60
    }
  ]
  
  cache_key_policy = {
    include_host         = true
    include_protocol     = true
    include_query_string = true
    query_string_whitelist = ["id", "lang"]
    query_string_blacklist = []
  }
  
  # CORS Configuration
  cors_origins = ["*"]
  cors_methods = ["GET", "HEAD", "OPTIONS"]
  cors_response_headers = ["*"]
  cors_max_age_seconds = 3600
  
  # Content Management
  enable_versioning = true
  object_age_days   = 30
  
  # URL Mapping
  host_rules = [
    {
      hosts        = ["cdn.example.com"]
      path_matcher = "main"
    }
  ]
  
  path_rules = {
    "main" = [
      {
        paths = ["/static/*"]
      }
    ]
  }
  
  create_ip = true
}
