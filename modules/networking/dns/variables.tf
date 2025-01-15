variable "project_id" {
  description = "The project ID to manage the Cloud DNS resources"
  type        = string
}

variable "zone_name" {
  description = "The name of the zone"
  type        = string
}

variable "dns_name" {
  description = "The DNS name of the zone, must end with a period"
  type        = string
}

variable "description" {
  description = "A description of the zone"
  type        = string
  default     = ""
}

variable "private_zone" {
  description = "Whether this is a private zone or not"
  type        = bool
  default     = false
}

variable "networks" {
  description = "List of VPC network self links that the zone will be available in"
  type        = list(string)
  default     = []
}

variable "enable_dnssec" {
  description = "Enable DNSSEC for this zone"
  type        = bool
  default     = false
}

variable "dnssec_key_algorithm" {
  description = "The algorithm to use for DNSSEC keys"
  type        = string
  default     = "rsasha256"
}

variable "dnssec_key_length" {
  description = "The length of the keys in bits"
  type        = number
  default     = 2048
}

variable "force_destroy" {
  description = "Set to true to delete all records in the zone"
  type        = bool
  default     = false
}

variable "labels" {
  description = "A map of labels to apply to the zone"
  type        = map(string)
  default     = {}
}

variable "records" {
  description = "List of DNS records to create"
  type = list(object({
    name    = string
    type    = string
    ttl     = number
    records = list(string)
  }))
  default = []
}

variable "enable_inbound_forwarding" {
  description = "Enable inbound forwarding for this zone"
  type        = bool
  default     = false
}

variable "enable_logging" {
  description = "Enable query logging for this zone"
  type        = bool
  default     = false
}
