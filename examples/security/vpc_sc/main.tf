provider "google" {
  project = var.project_id
  region  = var.region
}

module "vpc_sc" {
  source = "../../../modules/security/vpc_sc"

  organization_id = var.organization_id
  create_access_policy = true
  policy_title = "Organization Security Policy"
  policy_scopes = ["projects/${var.project_id}"]

  # Access Levels
  access_levels = {
    "trusted_locations" = {
      title = "Trusted Locations"
      ip_subnetworks = ["10.0.0.0/8", "172.16.0.0/12"]
      regions = ["us-central1", "us-west1"]
      negate  = false
      combining_function = "AND"
    },
    "corporate_devices" = {
      title = "Corporate Devices"
      members = {
        groups = ["group:corporate-devices@example.com"]
      }
      required_access_levels = ["trusted_locations"]
      combining_function = "AND"
    }
  }

  # Service Perimeters
  service_perimeters = {
    "data_perimeter" = {
      title = "Data Services Perimeter"
      restricted_services = [
        "bigquery.googleapis.com",
        "storage.googleapis.com",
        "cloudsql.googleapis.com"
      ]
      access_levels = ["trusted_locations", "corporate_devices"]
      
      vpc_accessible_services = {
        enable_restriction = true
        allowed_services = [
          "compute.googleapis.com",
          "cloudsql.googleapis.com"
        ]
      }

      resources = [
        {
          type   = "project"
          values = ["projects/${var.project_id}"]
        }
      ]

      ingress_policies = [
        {
          source_access_level = "trusted_locations"
          source_resources   = ["projects/${var.project_id}"]
          identity_type      = "ANY_IDENTITY"
          identities         = []
        }
      ]

      egress_policies = [
        {
          identity_type = "ANY_USER_ACCOUNT"
          identities    = []
        }
      ]

      use_explicit_dry_run_spec = true
      
      spec = {
        restricted_services = [
          "bigquery.googleapis.com",
          "storage.googleapis.com"
        ]
        access_levels = ["trusted_locations"]
        resources     = ["projects/${var.project_id}"]
        vpc_accessible_services = {
          enable_restriction = true
          allowed_services  = ["compute.googleapis.com"]
        }
      }
    }
  }
}
