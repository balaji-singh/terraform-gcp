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
  cluster_name  = var.cluster_name      # Name of the GKE cluster
  location      = "${var.region}-a"       # Location for the cluster
  network       = "default"                # Network to use
  subnetwork    = "default"                # Subnetwork to use

  # IP ranges for pods and services
  # The following parameters configure the IP ranges for pods and services.
  cluster_secondary_range_name  = var.cluster_secondary_range_name  # Secondary range for pods
  services_secondary_range_name = var.services_secondary_range_name   # Secondary range for services

  # Private cluster configuration
  # The following parameters configure the private cluster settings.
  enable_private_nodes    = true                     # Enable private nodes
  enable_private_endpoint = false                    # Disable private endpoint
  master_ipv4_cidr_block = var.master_ipv4_cidr_block       # CIDR block for master

  # Master authorized networks
  # The following parameter configures the authorized networks for the master.
  master_authorized_networks = var.master_authorized_networks

  # Node configuration
  # The following parameters configure the nodes in the cluster.
  node_count    = var.node_count                 # Number of nodes in the cluster
  machine_type  = var.machine_type         # Machine type for nodes
  disk_size_gb  = var.disk_size_gb               # Disk size in GB
  disk_type     = var.disk_type            # Disk type

  # Node labels
  # The following parameter configures the labels for the nodes.
  node_labels = var.node_labels  # Labels for nodes

  # Node tags
  # The following parameter configures the tags for the nodes.
  node_tags = var.node_tags  # Tags for nodes
  maintenance_recurrence = var.maintenance_recurrence  # Maintenance recurrence
  maintenance_end_time = var.maintenance_end_time  # Maintenance end time
  maintenance_start_time = var.maintenance_start_time  # Maintenance start time
}
