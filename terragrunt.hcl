locals {
  # Load environment variables
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  
  # Extract commonly used variables
  project_id      = local.env_vars.locals.project_id
  region          = local.env_vars.locals.region
  environment     = local.env_vars.locals.environment
  organization_id = local.env_vars.locals.organization_id
}

# Remote state configuration
remote_state {
  backend = "gcs"
  config = {
    bucket         = "${local.project_id}-terraform-state"
    prefix         = "${path_relative_to_include()}/terraform.tfstate"
    location       = local.region
    project        = local.project_id
    encryption_key = get_env("GOOGLE_ENCRYPTION_KEY", "")
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "google" {
  project = "${local.project_id}"
  region  = "${local.region}"
}

provider "google-beta" {
  project = "${local.project_id}"
  region  = "${local.region}"
}
EOF
}

# Global variables
inputs = merge(
  local.env_vars.locals,
  {
    # Common tags
    labels = {
      environment = local.environment
      managed_by  = "terragrunt"
      project     = local.project_id
    }

    # Default KMS configuration
    kms_config = {
      location = local.region
      key_ring = "terraform-keyring"
      keys     = ["terraform-key"]
    }

    # Default IAM configuration
    iam_config = {
      admin_group = "gcp-admins@example.com"
      audit_group = "gcp-auditors@example.com"
    }
  }
)

# Before hook to ensure GCP APIs are enabled
terraform {
  before_hook "before_hook" {
    commands = ["apply", "plan"]
    execute  = [
      "gcloud", "services", "enable",
      "cloudresourcemanager.googleapis.com",
      "iam.googleapis.com",
      "compute.googleapis.com",
      "container.googleapis.com",
      "secretmanager.googleapis.com",
      "cloudasset.googleapis.com",
      "cloudbuild.googleapis.com",
      "monitoring.googleapis.com",
      "logging.googleapis.com"
    ]
  }
}

# Retry configuration
retryable_errors = [
  ".*Error 409: The resource.*",
  ".*Error 429: Rate Limit Exceeded.*",
  ".*Error 500: Internal Server Error.*",
  ".*Error 502: Bad Gateway.*",
  ".*Error 503: Service Unavailable.*",
  ".*Error 504: Gateway Timeout.*",
]
