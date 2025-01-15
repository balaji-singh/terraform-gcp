locals {
  # Load environment variables
  project_vars = yamldecode(file(find_in_parent_folders("project.yaml")))
  environment_vars = yamldecode(file(find_in_parent_folders("env.yaml")))
  region_vars = yamldecode(file(find_in_parent_folders("region.yaml")))

  # Extract commonly used variables
  project_id = local.project_vars.project_id
  environment = local.environment_vars.environment
  region = local.region_vars.region
  organization_id = local.project_vars.organization_id
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

# Include GKE module
include "modules/gke"

# Global inputs for all modules
inputs = merge(
  local.environment_vars,
  {
    project_id = "your-project-id"
    region     = "us-central1"
    cluster_name = "your-cluster-name"
    node_count = 3
    node_machine_type = "e2-medium"
    # Add more inputs as required
  }
)

# Terraform configuration
terraform {
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()

    arguments = [
      "-var-file=${get_terragrunt_dir()}/../../config/common.tfvars",
      "-var-file=${get_terragrunt_dir()}/../../config/${local.environment}.tfvars"
    ]
  }

  before_hook "before_hook" {
    commands = ["apply", "plan"]
    execute  = ["echo", "Running Terraform"]
  }

  after_hook "after_hook" {
    commands = ["apply", "plan"]
    execute  = ["echo", "Terraform execution complete"]
  }
}
