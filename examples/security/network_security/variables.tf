variable "project_id" {
  description = "The ID of the project where resources will be created"
  type        = string
}

variable "region" {
  description = "The region where resources will be created"
  type        = string
  default     = "us-central1"
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "secure-network"
}

variable "iap_members" {
  description = "List of members for IAP access"
  type        = list(string)
  default     = []
}

variable "notification_channels" {
  description = "List of notification channel IDs"
  type        = list(string)
  default     = []
}

variable "network_config" {
  description = "Network configuration settings"
  type = object({
    enable_private_ip_google_access = bool
    enable_flow_logs = bool
    enable_nat = bool
    enable_iap = bool
  })
  default = {
    enable_private_ip_google_access = true
    enable_flow_logs = true
    enable_nat = true
    enable_iap = true
  }
}

variable "security_controls" {
  description = "Security control settings"
  type = object({
    enable_cloud_armor = bool
    enable_ddos_protection = bool
    enable_ssl_policy = bool
    enable_private_connect = bool
  })
  default = {
    enable_cloud_armor = true
    enable_ddos_protection = true
    enable_ssl_policy = true
    enable_private_connect = true
  }
}

variable "waf_rules" {
  description = "WAF rule configurations"
  type = map(object({
    priority = number
    action = string
    description = string
    expression = string
  }))
  default = {
    sql_injection = {
      priority = 1000
      action = "deny(403)"
      description = "Block SQL injection"
      expression = "evaluatePreconfiguredExpr('sqli-stable')"
    }
    xss = {
      priority = 1001
      action = "deny(403)"
      description = "Block XSS"
      expression = "evaluatePreconfiguredExpr('xss-stable')"
    }
  }
}

variable "firewall_rules" {
  description = "Firewall rule configurations"
  type = map(object({
    direction = string
    priority = number
    ranges = list(string)
    allow = list(object({
      protocol = string
      ports = list(string)
    }))
    deny = list(object({
      protocol = string
      ports = optional(list(string))
    }))
  }))
  default = {}
}

variable "subnet_config" {
  description = "Subnet configurations"
  type = map(object({
    ip_cidr_range = string
    region = string
    private_ip_google_access = bool
    secondary_ranges = optional(map(list(object({
      range_name = string
      ip_cidr_range = string
    }))))
  }))
  default = {}
}

variable "nat_config" {
  description = "Cloud NAT configuration"
  type = object({
    min_ports_per_vm = number
    enable_endpoint_independent_mapping = bool
    enable_dynamic_port_allocation = bool
    log_config = object({
      enable = bool
      filter = string
    })
  })
  default = {
    min_ports_per_vm = 64
    enable_endpoint_independent_mapping = true
    enable_dynamic_port_allocation = true
    log_config = {
      enable = true
      filter = "ERRORS_ONLY"
    }
  }
}

variable "monitoring_config" {
  description = "Monitoring configuration"
  type = object({
    alert_thresholds = map(number)
    evaluation_periods = map(string)
    notification_channels = list(string)
  })
  default = {
    alert_thresholds = {
      network_traffic = 1000000000
      error_rate = 0.01
      latency = 1000
    }
    evaluation_periods = {
      network_traffic = "300s"
      error_rate = "300s"
      latency = "300s"
    }
    notification_channels = []
  }
}

variable "ssl_policy_config" {
  description = "SSL policy configuration"
  type = object({
    profile = string
    min_tls_version = string
    custom_features = optional(list(string))
  })
  default = {
    profile = "RESTRICTED"
    min_tls_version = "TLS_1_2"
  }
}

variable "flow_logs_config" {
  description = "VPC Flow Logs configuration"
  type = object({
    aggregation_interval = string
    flow_sampling = number
    metadata = string
    filter = string
  })
  default = {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling = 0.5
    metadata = "INCLUDE_ALL_METADATA"
    filter = ""
  }
}

variable "ddos_protection_config" {
  description = "DDoS protection configuration"
  type = object({
    rate_limit_threshold = number
    ban_duration_sec = number
    evaluation_window_sec = number
  })
  default = {
    rate_limit_threshold = 100
    ban_duration_sec = 300
    evaluation_window_sec = 60
  }
}

variable "compliance_requirements" {
  description = "Compliance requirements for network security"
  type = map(object({
    enabled = bool
    controls = list(string)
  }))
  default = {
    pci_dss = {
      enabled = true
      controls = [
        "firewall_rules",
        "encryption_in_transit",
        "network_segmentation"
      ]
    }
    hipaa = {
      enabled = true
      controls = [
        "access_control",
        "audit_logging",
        "encryption"
      ]
    }
  }
}
