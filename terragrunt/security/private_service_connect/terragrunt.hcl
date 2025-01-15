include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/security/private_service_connect"
}

dependency "network" {
  config_path = "../network"
}

inputs = {
  service_attachments = {
    "secure-service" = {
      name = "secure-service-attachment"
      description = "Secure service attachment for internal services"
      network = dependency.network.outputs.network_name
      nat_subnets = ["secure-nat-subnet"]
      connection_preference = "ACCEPT_AUTOMATIC"
      target_service = "servicenetworking.googleapis.com"
    }
  }

  endpoints = {
    "internal-api" = {
      name = "internal-api-endpoint"
      network = dependency.network.outputs.network_name
      service_attachment = "secure-service"
      ip_address = "10.0.0.2"
      port = 443
    }
  }

  forwarding_rules = {
    "secure-forward" = {
      name = "secure-forwarding-rule"
      target = "internal-api"
      ip_address = "10.0.0.3"
      ports = ["443"]
      network = dependency.network.outputs.network_name
    }
  }

  security_policies = {
    "psc-policy" = {
      name = "psc-security-policy"
      type = "SECURITY_POLICY"
      rules = [
        {
          priority = 1000
          match = {
            config = {
              src_ip_ranges = ["10.0.0.0/8"]
            }
            versioned_expr = "SRC_IPS_V1"
          }
          action = "allow"
        },
        {
          priority = 2000
          match = {
            config = {
              src_ip_ranges = ["0.0.0.0/0"]
            }
            versioned_expr = "SRC_IPS_V1"
          }
          action = "deny"
        }
      ]
    }
  }

  dns_zones = {
    "psc-zone" = {
      name = "psc-private-zone"
      dns_name = "psc.internal."
      visibility = "private"
      networks = [dependency.network.outputs.network_name]
    }
  }

  service_directory = {
    "psc-directory" = {
      name = "psc-service-directory"
      location = local.region
      namespaces = {
        "secure-ns" = {
          name = "secure-namespace"
          services = {
            "internal-api" = {
              name = "internal-api"
              endpoints = ["internal-api-endpoint"]
              metadata = {
                protocol = "https"
                version = "v1"
              }
            }
          }
        }
      }
    }
  }
}
