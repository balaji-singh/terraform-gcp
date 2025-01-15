include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/security/container"
}

dependency "network" {
  config_path = "../network"
}

dependency "kms" {
  config_path = "../kms"
}

inputs = {
  cluster_config = {
    name = "secure-cluster"
    network = dependency.network.outputs.network_name
    subnetwork = dependency.network.outputs.subnet_names[0]
    
    private_cluster_config = {
      enable_private_nodes = true
      enable_private_endpoint = true
      master_ipv4_cidr_block = "172.16.0.0/28"
    }

    master_authorized_networks_config = {
      cidr_blocks = [
        {
          cidr_block = "10.0.0.0/8"
          display_name = "internal"
        }
      ]
    }

    workload_identity_config = {
      workload_pool = "${local.project_id}.svc.id.goog"
    }

    binary_authorization = {
      evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
    }

    security_posture_config = {
      mode = "BASIC"
      vulnerability_mode = "VULNERABILITY_ENABLED"
    }
  }

  registry_config = {
    location = "us"
    encryption_key = dependency.kms.outputs.crypto_keys["data-encryption-key"].id
    vulnerability_scanning = {
      enabled = true
    }
  }
}
