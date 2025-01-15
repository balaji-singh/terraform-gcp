variable "project_id" {
  description = "The project ID to host the cluster in"
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

variable "location" {
  description = "The location (region or zone) of the cluster"
  type        = string
}

variable "network" {
  description = "The VPC network to host the cluster in"
  type        = string
}

variable "subnetwork" {
  description = "The subnetwork to host the cluster in"
  type        = string
}

variable "cluster_secondary_range_name" {
  description = "The name of the secondary range to use for pods"
  type        = string
}

variable "services_secondary_range_name" {
  description = "The name of the secondary range to use for services"
  type        = string
}

variable "enable_private_nodes" {
  description = "Enable private nodes"
  type        = bool
  default     = true
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint"
  type        = bool
  default     = false
}

variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation to use for the hosted master network"
  type        = string
  default     = "172.16.0.0/28"
}

variable "master_authorized_networks" {
  description = "List of master authorized networks"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "maintenance_start_time" {
  description = "Time window specified for daily or recurring maintenance operations start time"
  type        = string
  default     = "05:00"
}

variable "maintenance_end_time" {
  description = "Time window specified for daily or recurring maintenance operations end time"
  type        = string
  default     = "09:00"
}

variable "maintenance_recurrence" {
  description = "Frequency of the recurring maintenance window"
  type        = string
  default     = "FREQ=WEEKLY;BYDAY=SA,SU"
}

variable "node_count" {
  description = "Number of nodes in the node pool"
  type        = number
  default     = 3
}

variable "machine_type" {
  description = "The name of a Google Compute Engine machine type"
  type        = string
  default     = "e2-medium"
}

variable "disk_size_gb" {
  description = "Size of the disk attached to each node"
  type        = number
  default     = 100
}

variable "disk_type" {
  description = "Type of the disk attached to each node"
  type        = string
  default     = "pd-standard"
}

variable "node_labels" {
  description = "The Kubernetes labels (key/value pairs) to be applied to each node"
  type        = map(string)
  default     = {}
}

variable "node_tags" {
  description = "The network tags to be applied to each node"
  type        = list(string)
  default     = []
}

variable "max_surge" {
  description = "The maximum number of nodes that can be created beyond the desired number of nodes during an upgrade"
  type        = number
  default     = 1
}

variable "max_unavailable" {
  description = "The maximum number of nodes that can be unavailable during an upgrade"
  type        = number
  default     = 0
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled for the cluster"
  type        = bool
  default     = false
}

variable "remove_default_node_pool" {
  description = "Whether to remove the default node pool"
  type        = bool
  default     = true
}