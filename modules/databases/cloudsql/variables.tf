variable "project_id" {
  description = "The project ID to manage the Cloud SQL resources"
  type        = string
}

variable "instance_name" {
  description = "The name of the Cloud SQL instance"
  type        = string
}

variable "database_version" {
  description = "The database version to use"
  type        = string
}

variable "region" {
  description = "The region of the Cloud SQL resources"
  type        = string
}

variable "tier" {
  description = "The tier for the master instance"
  type        = string
  default     = "db-f1-micro"
}

variable "availability_type" {
  description = "The availability type for the master instance"
  type        = string
  default     = "REGIONAL"
}

variable "disk_size" {
  description = "The disk size for the master instance"
  type        = number
  default     = 10
}

variable "disk_type" {
  description = "The disk type for the master instance"
  type        = string
  default     = "PD_SSD"
}

variable "backup_enabled" {
  description = "True if backup configuration is enabled"
  type        = bool
  default     = true
}

variable "binary_log_enabled" {
  description = "True if binary logging is enabled"
  type        = bool
  default     = false
}

variable "backup_start_time" {
  description = "HH:MM format time indicating when backup configuration starts"
  type        = string
  default     = "23:00"
}

variable "transaction_log_retention_days" {
  description = "The number of days of transaction logs we retain"
  type        = number
  default     = 7
}

variable "retained_backups" {
  description = "Number of backups to retain"
  type        = number
  default     = 7
}

variable "public_ip_enabled" {
  description = "Whether this Cloud SQL instance should be assigned a public IP address"
  type        = bool
  default     = false
}

variable "private_network" {
  description = "The VPC network from which the Cloud SQL instance is accessible for private IP"
  type        = string
  default     = null
}

variable "require_ssl" {
  description = "True if the instance should require SSL/TLS for connections"
  type        = bool
  default     = true
}

variable "authorized_networks" {
  description = "List of external networks that can access the database instance"
  type = list(object({
    name = string
    cidr = string
  }))
  default = []
}

variable "max_connections" {
  description = "Maximum number of allowed connections"
  type        = number
  default     = 100
}

variable "maintenance_window_day" {
  description = "Day of week (1-7), starting on Monday, for maintenance window"
  type        = number
  default     = 1
}

variable "maintenance_window_hour" {
  description = "Hour of day (0-23) for maintenance window"
  type        = number
  default     = 23
}

variable "maintenance_window_update_track" {
  description = "Receive updates earlier (canary) or later (stable)"
  type        = string
  default     = "stable"
}

variable "query_insights_enabled" {
  description = "True if query insights are enabled"
  type        = bool
  default     = true
}

variable "query_string_length" {
  description = "Maximum query string length stored in traces"
  type        = number
  default     = 1024
}

variable "record_application_tags" {
  description = "True if query insights should record application tags"
  type        = bool
  default     = false
}

variable "record_client_address" {
  description = "True if query insights should record client address"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Used to block Terraform from deleting a SQL Instance"
  type        = bool
  default     = true
}

variable "databases" {
  description = "List of databases to be created in your instance"
  type        = list(string)
  default     = []
}

variable "users" {
  description = "List of users to be created in your instance"
  type = list(object({
    name     = string
    password = string
  }))
  default = []
}

variable "db_charset" {
  description = "The charset for the default database"
  type        = string
  default     = "UTF8"
}

variable "db_collation" {
  description = "The collation for the default database"
  type        = string
  default     = "en_US.UTF8"
}

variable "module_depends_on" {
  description = "List of modules or resources this module depends on"
  type        = list(any)
  default     = []
}
