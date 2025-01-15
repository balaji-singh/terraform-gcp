variable "project_id" {
  description = "The ID of the project where resources will be created"
  type        = string
}

variable "dashboards" {
  description = "Map of monitoring dashboards to create"
  type = map(object({
    display_name = string
    grid_layout = object({
      columns = number
      widgets = list(any)
    })
  }))
  default = {}
}

variable "alert_policies" {
  description = "Map of alert policies to create"
  type = map(object({
    display_name = string
    enabled      = bool
    documentation = object({
      content   = string
      mime_type = string
    })
    condition = object({
      display_name = string
      filter       = string
      duration     = string
      comparison   = string
      threshold_value = number
      alignment_period     = string
      per_series_aligner   = string
      cross_series_reducer = string
      group_by_fields     = list(string)
      trigger = object({
        count   = number
        percent = number
      })
    })
    notification_channels = list(string)
    labels               = map(string)
  }))
  default = {}
}

variable "notification_channels" {
  description = "Map of notification channels to create"
  type = map(object({
    display_name = string
    type         = string
    labels       = map(string)
    sensitive_labels = object({
      auth_token  = string
      password    = string
      service_key = string
    })
    user_labels = map(string)
    enabled     = bool
    verification_status = string
  }))
  default = {}
}

variable "uptime_checks" {
  description = "Map of uptime checks to create"
  type = map(object({
    display_name = string
    timeout      = string
    period       = string
    http_check = object({
      path         = string
      port         = number
      use_ssl      = bool
      validate_ssl = bool
      headers      = map(string)
    })
    tcp_check = object({
      port = number
    })
    monitored_resource = object({
      type   = string
      labels = map(string)
    })
    selected_regions = list(string)
  }))
  default = {}
}
