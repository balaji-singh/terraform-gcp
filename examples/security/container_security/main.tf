/**
 * Container Security Configuration
 * This example demonstrates comprehensive container security controls
 */

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# GKE Cluster with Security Controls
module "gke_security" {
  source = "../../../modules/security/gke"

  project_id = var.project_id
  location   = var.region

  clusters = {
    "secure-cluster" = {
      name = "secure-cluster"
      network = var.network_name
      subnetwork = var.subnet_name
      
      private_cluster_config = {
        enable_private_nodes = true
        enable_private_endpoint = true
        master_ipv4_cidr_block = "172.16.0.0/28"
      }

      master_authorized_networks_config = {
        cidr_blocks = var.authorized_networks
      }

      workload_identity_config = {
        workload_pool = "${var.project_id}.svc.id.goog"
      }

      binary_authorization = {
        evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
      }

      security_posture_config = {
        mode = "BASIC"
        vulnerability_mode = "VULNERABILITY_ENABLED"
      }

      network_policy = {
        enabled = true
        provider = "CALICO"
      }

      pod_security_policy_config = {
        enabled = true
      }

      authenticator_groups_config = {
        security_group = "gke-security-groups@yourdomain.com"
      }

      release_channel = {
        channel = "REGULAR"
      }

      maintenance_policy = {
        recurring_window = {
          start_time = "2024-01-01T00:00:00Z"
          end_time = "2024-01-02T00:00:00Z"
          recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"
        }
      }
    }
  }
}

# Binary Authorization
module "binary_auth" {
  source = "../../../modules/security/binary_authorization"

  project_id = var.project_id

  policy_config = {
    global_policy_evaluation_mode = "ENABLE"
    default_admission_rule = {
      evaluation_mode  = "REQUIRE_ATTESTATION"
      enforcement_mode = "ENFORCED_BLOCK_AND_AUDIT_LOG"
      attestation_patterns = {
        google_binary_authorization_attestor = {
          name = "security-attestor"
          note_reference = "projects/${var.project_id}/notes/security-note"
        }
      }
    }
  }
}

# Container-Optimized OS
module "cos_security" {
  source = "../../../modules/security/cos"

  project_id = var.project_id

  instances = {
    "secure-cos" = {
      name         = "secure-cos"
      machine_type = "e2-standard-2"
      zone         = "${var.region}-a"
      network      = var.network_name
      subnetwork   = var.subnet_name

      boot_disk = {
        initialize_params = {
          image = "cos-cloud/cos-stable"
          size  = 20
        }
      }

      metadata = {
        user-data = file("${path.module}/cloud-config.yaml")
      }

      service_account = {
        email  = var.service_account_email
        scopes = ["cloud-platform"]
      }
    }
  }
}

# Container Registry Security
module "container_registry" {
  source = "../../../modules/security/container_registry"

  project_id = var.project_id

  registry_config = {
    location = "us"
    encryption_key = var.kms_key_name
  }

  vulnerability_scanning = {
    scanning_config = {
      enabled = true
    }
  }
}

# Container Analysis
module "container_analysis" {
  source = "../../../modules/security/container_analysis"

  project_id = var.project_id

  notes = {
    "vulnerability-note" = {
      short_description = "Container vulnerability scanning"
      long_description = "Results of vulnerability scanning for container images"
      vulnerability = {
        details = [
          {
            affected_cpe_uri = "cpe:/o:debian:debian_linux:9"
            affected_package = "openssl"
            min_affected_version = {
              kind = "MINIMUM"
            }
            max_affected_version = {
              kind = "MAXIMUM"
            }
          }
        ]
      }
    }
  }
}

# Workload Identity
module "workload_identity" {
  source = "../../../modules/security/workload_identity"

  project_id = var.project_id

  service_accounts = {
    "workload-sa" = {
      account_id   = "workload-sa"
      display_name = "Workload Identity Service Account"
      description  = "Service account for workload identity"
    }
  }

  workload_identity_bindings = {
    "k8s-binding" = {
      service_account_id = "workload-sa"
      namespace         = "default"
      k8s_sa_name       = "k8s-sa"
    }
  }
}

# Pod Security Standards
module "pod_security" {
  source = "../../../modules/security/pod_security"

  project_id = var.project_id
  cluster_name = module.gke_security.clusters["secure-cluster"].name
  location     = var.region

  policies = {
    "restricted" = {
      enforcement = "enforcing"
      severity    = "high"
      parameters = {
        hostNetwork = false
        hostPID = false
        hostIPC = false
        privileged = false
        allowPrivilegeEscalation = false
        readOnlyRootFilesystem = true
      }
    }
  }
}

# Network Policy
module "network_policy" {
  source = "../../../modules/security/network_policy"

  project_id = var.project_id
  cluster_name = module.gke_security.clusters["secure-cluster"].name
  location     = var.region

  policies = {
    "default-deny" = {
      namespace = "default"
      pod_selector = {}
      policy_types = ["Ingress", "Egress"]
    }
    "allow-internal" = {
      namespace = "default"
      pod_selector = {
        match_labels = {
          app = "internal"
        }
      }
      ingress = [{
        from = [{
          namespace_selector = {
            match_labels = {
              name = "default"
            }
          }
        }]
      }]
    }
  }
}

# Container Security Monitoring
module "container_monitoring" {
  source = "../../../modules/security/monitoring"

  project_id = var.project_id

  alert_policies = {
    "container-security" = {
      display_name = "Container Security Alerts"
      combiner     = "OR"
      conditions = [
        {
          display_name = "Container Vulnerability Found"
          condition_threshold = {
            filter     = "resource.type=\"container\" severity=\"HIGH\""
            duration   = "0s"
            comparison = "COMPARISON_GT"
            threshold_value = 0
          }
        }
      ]
    }
  }

  notification_channels = var.notification_channels
}
