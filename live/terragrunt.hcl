locals {
  # Load common variables
  common_vars = yamldecode(file(find_in_parent_folders("common.yaml")))
  
  # Extract commonly used variables
  project_id = local.common_vars.project_id
  environment = local.common_vars.environment
  region = local.common_vars.region
  organization_id = local.common_vars.organization_id
}

# Remote state configuration
remote_state {
  backend = "gcs"
  config = {
    project  = local.project_id
    location = local.region
    bucket   = "${local.project_id}-terraform-state"
    prefix   = "${path_relative_to_include()}/terraform.tfstate"

    gcs_bucket_labels = {
      environment = local.environment
      managed_by  = "terragrunt"
    }
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Generate provider configuration
generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
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

# Global inputs for all modules
inputs = merge(
  local.common_vars,
  {
    labels = {
      environment = local.environment
      managed_by  = "terragrunt"
      terraform   = "true"
    }
  }
)
