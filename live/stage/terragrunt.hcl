locals {
  environment_vars = yamldecode(file("env.yaml"))
}

include "root" {
  path = find_in_parent_folders()
}

include "../../modules/gke"

inputs = merge(
  local.environment_vars,
  {
    environment = "stage"
    project_id = "your-project-id"
    region     = "us-central1"
    cluster_name = "your-cluster-name"
    node_count = 3
    node_machine_type = "e2-medium"
    # Add more inputs as required
  }
)
