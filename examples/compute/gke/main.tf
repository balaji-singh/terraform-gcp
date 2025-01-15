# Google Cloud provider configuration
# This section configures the Google Cloud provider with the project ID and region.
provider "google" {
  project = var.project_id  # The GCP project ID
  region  = var.region     # The region for resource deployment
}

# GKE module configuration
# This section configures the GKE module with the required parameters.
module "gke" {
  # Path to the GKE module
  source = "../../../modules/compute/gke"

  # Project ID for GKE
  project_id    = var.project_id

  # Cluster configuration
  # The following parameters configure the GKE cluster.
  cluster_name  = "my-gke-cluster"        # Name of the GKE cluster
  location      = "${var.region}-a"       # Location for the cluster
  network       = "default"                # Network to use
  subnetwork    = "default"                # Subnetwork to use

  # IP ranges for pods and services
  # The following parameters configure the IP ranges for pods and services.
  cluster_secondary_range_name  = "pod-range"  # Secondary range for pods
  services_secondary_range_name = "svc-range"   # Secondary range for services

  # Private cluster configuration
  # The following parameters configure the private cluster settings.
  enable_private_nodes    = true                     # Enable private nodes
  enable_private_endpoint = false                    # Disable private endpoint
  master_ipv4_cidr_block = "172.16.0.0/28"       # CIDR block for master

  # Master authorized networks
  # The following parameter configures the authorized networks for the master.
  master_authorized_networks = [
    {
      cidr_block   = "10.0.0.0/8"        # Authorized network CIDR
      display_name = "internal"            # Display name for the network
    }
  ]

  # Node configuration
  # The following parameters configure the nodes in the cluster.
  node_count    = 3                         # Number of nodes in the cluster
  machine_type  = "e2-standard-2"         # Machine type for nodes
  disk_size_gb  = 100                       # Disk size in GB
  disk_type     = "pd-standard"            # Disk type

  # Node labels
  # The following parameter configures the labels for the nodes.
  node_labels = {
    environment = "production"            # Label for environment
    team        = "devops"                # Label for team
  }

  # Node tags
  # The following parameter configures the tags for the nodes.
  node_tags = ["gke-node", "production"]  # Tags for nodes
  maintenance_recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"  # Maintenance recurrence
  maintenance_end_time = "2025-01-01T00:00:00Z"  # Maintenance end time
  maintenance_start_time = "2026-01-01T00:00:00Z"  # Maintenance start time
}
