include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/security/network"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    network_name = "mock-network"
    network_id   = "mock-network-id"
  }
}

inputs = {
  network_name = "secure-network"
  
  subnets = {
    "private-subnet" = {
      name = "private-subnet"
      ip_cidr_range = "10.0.1.0/24"
      region = local.region
      private_ip_google_access = true
    }
  }

  firewall_rules = {
    "allow-internal" = {
      name = "allow-internal"
      direction = "INGRESS"
      priority = 1000
      ranges = ["10.0.0.0/8"]
      allow = [{
        protocol = "tcp"
        ports    = ["443", "8443"]
      }]
    }
  }
}
