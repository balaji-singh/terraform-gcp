variable "project_id" {
  description = "The ID of the project where this instance will be created"
  type        = string
}

variable "instance_name" {
  description = "A unique name for the instance"
  type        = string
}

variable "machine_type" {
  description = "The machine type to create"
  type        = string
  default     = "e2-medium"
}

variable "zone" {
  description = "The zone where the instance will be created"
  type        = string
}

variable "boot_disk_image" {
  description = "The image from which to initialize this disk"
  type        = string
  default     = "debian-cloud/debian-11"
}

variable "boot_disk_size_gb" {
  description = "The size of the boot disk in GB"
  type        = number
  default     = 50
}

variable "boot_disk_type" {
  description = "The GCE disk type. Can be either pd-standard, pd-balanced or pd-ssd"
  type        = string
  default     = "pd-standard"
}

variable "network" {
  description = "The name or self_link of the network to attach this interface to"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "The name or self_link of the subnetwork to attach this interface to"
  type        = string
  default     = "default"
}

variable "enable_public_ip" {
  description = "Whether to enable public IP for the instance"
  type        = bool
  default     = false
}

variable "metadata" {
  description = "Metadata key/value pairs to make available from within the instance"
  type        = map(string)
  default     = {}
}

variable "network_tags" {
  description = "Network tags to attach to the instance"
  type        = list(string)
  default     = []
}

variable "service_account_email" {
  description = "The service account e-mail address"
  type        = string
  default     = ""
}

variable "service_account_scopes" {
  description = "A list of service scopes"
  type        = list(string)
  default     = ["cloud-platform"]
}

variable "labels" {
  description = "A map of key/value label pairs to assign to the instance"
  type        = map(string)
  default     = {}
}
