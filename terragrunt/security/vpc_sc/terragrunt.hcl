include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/security/vpc_sc"
}

dependency "network" {
  config_path = "../network"
}

inputs = {
  access_policy = {
    title = "security-policy"
    scopes = ["projects/${local.project_id}"]
  }

  service_perimeters = {
    "security-perimeter" = {
      title = "security_perimeter"
      description = "Perimeter for sensitive data"
      status = {
        restricted_services = [
          "storage.googleapis.com",
          "bigquery.googleapis.com",
          "cloudfunctions.googleapis.com"
        ]
        access_levels = ["accessPolicies/${dependency.network.outputs.access_policy_id}/accessLevels/trusted_access"]
        resources = ["projects/${local.project_id}"]
      }
    }
  }
}
