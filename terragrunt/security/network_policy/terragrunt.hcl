include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/security/network_policy"
}

dependency "container" {
  config_path = "../container"
}

inputs = {
  network_policies = {
    "default-deny" = {
      name = "default-deny"
      description = "Default deny all ingress/egress traffic"
      cluster = dependency.container.outputs.cluster_name
      namespace = "default"
      pod_selector = {}
      policy_types = ["Ingress", "Egress"]
    }
    "allow-internal" = {
      name = "allow-internal"
      description = "Allow internal traffic between pods"
      cluster = dependency.container.outputs.cluster_name
      namespace = "default"
      pod_selector = {}
      ingress = [
        {
          from = [
            {
              pod_selector = {}
              namespace_selector = {
                match_labels = {
                  name = "default"
                }
              }
            }
          ]
        }
      ]
    }
  }

  namespace_policies = {
    "prod-isolation" = {
      name = "prod-isolation"
      namespaces = ["prod"]
      ingress = {
        from = [
          {
            namespace_selector = {
              match_labels = {
                environment = "prod"
              }
            }
          }
        ]
      }
      egress = {
        to = [
          {
            namespace_selector = {
              match_labels = {
                environment = "prod"
              }
            }
          }
        ]
      }
    }
  }

  service_policies = {
    "api-access" = {
      name = "api-access"
      services = ["api-service"]
      ingress = {
        ports = ["80", "443"]
        from = [
          {
            pod_selector = {
              match_labels = {
                role = "frontend"
              }
            }
          }
        ]
      }
    }
  }

  monitoring_config = {
    metrics = {
      "policy_violations" = {
        type = "custom.googleapis.com/network/policy_violations"
        description = "Network policy violations"
      }
    }
    alerts = {
      "violation_alert" = {
        condition = "policy_violations > 10"
        notification_channels = ["email", "slack"]
      }
    }
  }

  logging_config = {
    "policy_logs" = {
      log_type = "network-policy"
      filter = "resource.type=k8s_container"
      destination = "logging.googleapis.com"
    }
  }
}
