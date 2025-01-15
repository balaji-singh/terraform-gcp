provider "google" {
  project = var.project_id
  region  = var.region
}

module "gke" {
  source = "../../../modules/compute/gke"

  project_id    = var.project_id
  cluster_name  = "my-gke-cluster"
  location      = "${var.region}-a"
  network       = "default"
  subnetwork    = "default"

  cluster_secondary_range_name  = "pod-range"
  services_secondary_range_name = "svc-range"

  enable_private_nodes    = true
  enable_private_endpoint = false
  master_ipv4_cidr_block = "172.16.0.0/28"

  master_authorized_networks = [
    {
      cidr_block   = "10.0.0.0/8"
      display_name = "internal"
    }
  ]

  node_count    = 3
  machine_type  = "e2-standard-2"
  disk_size_gb  = 100
  disk_type     = "pd-standard"

  node_labels = {
    environment = "production"
    team        = "devops"
  }

  node_tags = ["gke-node", "production"]
}
