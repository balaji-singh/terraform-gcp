variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
  default = "dev-project-2025-447919"
}

variable "region" {
  description = "The region where resources will be deployed"
  type        = string
  default = "us-central1"
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default = "dev-gke-cluster"
}

variable "network" {
  description = "The name of the VPC network"
  type        = string
  default = "dev-network"
}

variable "subnetwork" {
  description = "The name of the subnetwork"
  type        = string
  default = "dev-subnetwork"
}

variable "cluster_secondary_range_name" {
  description = "The name of the secondary range for pods"
  type        = string
  default = "pods-range"
}

variable "services_secondary_range_name" {
  description = "The name of the secondary range for services"
  type        = string
  default = "services-range"
}

variable "master_ipv4_cidr_block" {
  description = "The CIDR block for the master"
  type        = string
  default = "10.0.0.0/28"
}

variable "node_count" {
  description = "The number of nodes in the node pool"
  type        = number
  default = 3
} 

variable "machine_type" {
  description = "The machine type for the nodes"
  type        = string
  default = "e2-standard-2"
} 

variable "disk_size_gb" {
  description = "The disk size for the nodes"
  type        = number
  default = 100
}

variable "disk_type" {
  description = "The disk type for the nodes"
  type        = string
  default = "pd-standard"
}

variable "node_labels" {
  description = "The labels for the nodes"
  type        = map(string)
  default = {
    "env" = "dev"
    "team" = "devops"
  }
} 

variable "node_tags" {
  description = "The tags for the nodes"
  type        = list(string)
  default = ["gke-node", "production"]
}

variable "maintenance_start_time" {
  description = "The start time for the maintenance window"
  type        = string
  default = "2025-01-01T00:00:00Z"
}

variable "maintenance_end_time" {
  description = "The end time for the maintenance window"
  type        = string
  default = "2026-01-01T00:00:00Z"
}

variable "maintenance_recurrence" {
  description = "The recurrence for the maintenance window"
  type        = string
  default = "FREQ=WEEKLY;BYDAY=SA,SU"
}

variable "node_metadata" {
  description = "The metadata for the nodes"
  type        = map(string)
  default = {
    "disable-legacy-endpoints" = "true"
  }
}
variable "master_authorized_networks" {
  description = "The authorized networks for the master"
  type        = list(map(string))
  default = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "all"
    }
  ]
}