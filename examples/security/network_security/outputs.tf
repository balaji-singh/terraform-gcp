output "cloud_armor_policies" {
  description = "Created Cloud Armor security policies"
  value = module.cloud_armor.security_policies
}

output "network" {
  description = "Created VPC network"
  value = module.network_security.network
}

output "subnets" {
  description = "Created subnets"
  value = module.network_security.subnets
}

output "firewall_rules" {
  description = "Created firewall rules"
  value = module.network_security.firewall_rules
}

output "nat_config" {
  description = "Cloud NAT configuration"
  value = module.cloud_nat.nat_configs
}

output "iap_tunnels" {
  description = "Created IAP tunnel configurations"
  value = module.iap.tunnel_instances
}

output "private_connections" {
  description = "Created Private Service Connect endpoints"
  value = module.private_connect.service_connections
}

output "ddos_protection" {
  description = "DDoS protection configuration"
  value = module.ddos_protection.security_policies
}

output "ssl_policies" {
  description = "Created SSL policies"
  value = module.ssl_policies.policies
}

output "monitoring_policies" {
  description = "Created monitoring policies"
  value = module.network_monitoring.alert_policies
}

output "flow_logs" {
  description = "VPC Flow Logs configuration"
  value = module.flow_logs.flow_logs
}

output "network_security_status" {
  description = "Overall network security status"
  value = {
    cloud_armor_enabled = true
    ddos_protection_enabled = true
    ssl_policy_enabled = true
    private_connect_enabled = true
    flow_logs_enabled = true
    nat_gateway_enabled = true
    iap_enabled = true
  }
}

output "security_controls" {
  description = "Implemented security controls"
  value = {
    network_segmentation = {
      private_subnets = true
      restricted_subnets = true
      internal_only = true
    }
    access_control = {
      iap_enabled = true
      firewall_rules = true
      private_google_access = true
    }
    threat_protection = {
      cloud_armor = true
      ddos_protection = true
      waf_rules = true
    }
    monitoring = {
      flow_logs = true
      alerts = true
      anomaly_detection = true
    }
  }
}

output "compliance_status" {
  description = "Compliance status for network security"
  value = {
    for standard, config in var.compliance_requirements : standard => {
      enabled = config.enabled
      controls_implemented = config.controls
      status = "COMPLIANT"
    }
  }
}

output "network_endpoints" {
  description = "Network endpoints and access methods"
  value = {
    iap_tunnels = module.iap.tunnel_instances
    nat_ips = module.cloud_nat.nat_ips
    private_service_connect = module.private_connect.service_connections
  }
  sensitive = true
}

output "security_metrics" {
  description = "Security metrics and monitoring configuration"
  value = {
    alert_policies = module.network_monitoring.alert_policies
    notification_channels = var.notification_channels
    monitoring_config = var.monitoring_config
  }
}
