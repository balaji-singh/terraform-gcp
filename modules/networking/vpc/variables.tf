variable "project_id" {
  description = "The ID of the project where this VPC will be created"
  type        = string
}

variable "network_name" {
  description = "The name of the network being created"
  type        = string
}

variable "routing_mode" {
  description = "The network routing mode (default 'GLOBAL')"
  type        = string
  default     = "GLOBAL"
}

variable "auto_create_subnetworks" {
  description = "When set to true, the network is created in 'auto subnet mode' and it will create a subnet for each region automatically across the 10.128.0.0/9 address range."
  type        = bool
  default     = false
}

variable "delete_default_routes_on_create" {
  description = "If set to true, default routes (0.0.0.0/0) will be deleted immediately after network creation"
  type        = bool
  default     = false
}

variable "mtu" {
  description = "The network MTU. Must be a value between 1460 and 1500 bytes"
  type        = number
  default     = 1460
}

variable "subnets" {
  description = "The list of subnets being created"
  type = map(object({
    region                   = string
    ip_cidr_range           = string
    private_ip_google_access = optional(bool, true)
    secondary_ip_ranges     = optional(map(string), {})
    flow_logs_interval      = optional(string, "INTERVAL_5_SEC")
    flow_logs_sampling      = optional(number, 0.5)
    flow_logs_metadata      = optional(string, "INCLUDE_ALL_METADATA")
  }))
  default = {}
}

variable "create_internal_firewall" {
  description = "Create firewall rule for internal network communication"
  type        = bool
  default     = true
}

variable "create_iap_firewall" {
  description = "Create firewall rule for IAP SSH access"
  type        = bool
  default     = true
}

variable "create_internet_route" {
  description = "Create internet route for the network"
  type        = bool
  default     = true
}

variable "cloud_nat_configs" {
  description = "Map of Cloud NAT configurations by region"
  type = map(object({
    router_asn = number
  }))
  default = {}
}
