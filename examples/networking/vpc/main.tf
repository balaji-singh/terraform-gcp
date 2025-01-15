provider "google" {
  project = var.project_id
  region  = var.region
}

module "vpc" {
  source = "../../../modules/networking/vpc"

  project_id   = var.project_id
  network_name = "my-vpc-network"

  # Network configuration
  routing_mode = "GLOBAL"
  mtu         = 1460

  # Subnet configuration
  subnets = {
    "subnet-us-central1" = {
      region        = "us-central1"
      ip_cidr_range = "10.0.0.0/20"
      secondary_ip_ranges = {
        "pod-range"     = "172.16.0.0/20"
        "service-range" = "172.16.16.0/20"
      }
    }
    "subnet-us-east1" = {
      region        = "us-east1"
      ip_cidr_range = "10.1.0.0/20"
    }
  }

  # Firewall configuration
  create_internal_firewall = true
  create_iap_firewall     = true

  # NAT configuration
  cloud_nat_configs = {
    "us-central1" = {
      router_asn = 64514
    }
    "us-east1" = {
      router_asn = 64515
    }
  }
}
