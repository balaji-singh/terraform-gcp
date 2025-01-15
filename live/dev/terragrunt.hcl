locals {
  environment_vars = yamldecode(file("env.yaml"))
}

include "root" {
  path = find_in_parent_folders()
}

inputs = merge(
  local.environment_vars,
  {
    environment = "dev"
  }
)
