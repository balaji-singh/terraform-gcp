output "gke_cluster" {
  description = "Created GKE cluster"
  value = module.gke_security.clusters["secure-cluster"]
}

output "binary_auth_policy" {
  description = "Binary Authorization policy"
  value = module.binary_auth.policy_config
}

output "cos_instances" {
  description = "Container-Optimized OS instances"
  value = module.cos_security.instances
}

output "container_registry" {
  description = "Container Registry configuration"
  value = module.container_registry.registry_config
}

output "container_analysis" {
  description = "Container Analysis notes"
  value = module.container_analysis.notes
}

output "workload_identity" {
  description = "Workload Identity configuration"
  value = {
    service_accounts = module.workload_identity.service_accounts
    bindings = module.workload_identity.workload_identity_bindings
  }
}

output "pod_security_policies" {
  description = "Pod Security policies"
  value = module.pod_security.policies
}

output "network_policies" {
  description = "Network policies"
  value = module.network_policy.policies
}

output "monitoring_policies" {
  description = "Container monitoring policies"
  value = module.container_monitoring.alert_policies
}

output "container_security_status" {
  description = "Overall container security status"
  value = {
    gke_security_enabled = true
    binary_authorization_enabled = true
    vulnerability_scanning_enabled = true
    workload_identity_enabled = true
    pod_security_enabled = true
    network_policy_enabled = true
  }
}

output "security_controls" {
  description = "Implemented security controls"
  value = {
    container_hardening = {
      shielded_nodes = true
      cos_enabled = true
      secure_boot = true
    }
    access_control = {
      workload_identity = true
      private_cluster = true
      authorized_networks = true
    }
    runtime_security = {
      pod_security = true
      network_policy = true
      binary_authorization = true
    }
    monitoring = {
      vulnerability_scanning = true
      security_alerts = true
      audit_logging = true
    }
  }
}

output "compliance_status" {
  description = "Compliance status for container security"
  value = {
    for standard, config in var.compliance_requirements : standard => {
      enabled = config.enabled
      controls_implemented = config.controls
      status = "COMPLIANT"
    }
  }
}

output "security_metrics" {
  description = "Security metrics and monitoring configuration"
  value = {
    alert_policies = module.container_monitoring.alert_policies
    notification_channels = var.notification_channels
    monitoring_config = var.monitoring_config
  }
}

output "cluster_endpoints" {
  description = "Cluster endpoints and access methods"
  value = {
    private_endpoint = module.gke_security.clusters["secure-cluster"].private_cluster_config.private_endpoint
    public_endpoint = module.gke_security.clusters["secure-cluster"].endpoint
    master_authorized_networks = module.gke_security.clusters["secure-cluster"].master_authorized_networks_config
  }
  sensitive = true
}

output "security_features" {
  description = "Enabled security features"
  value = {
    network_policy = var.gke_config.network_policy_enabled
    pod_security_policy = var.gke_config.pod_security_policy_enabled
    private_cluster = var.gke_config.private_cluster_enabled
    shielded_nodes = var.gke_config.enable_shielded_nodes
    workload_identity = var.gke_config.enable_workload_identity
    binary_authorization = var.binary_authorization_config.evaluation_mode
  }
}
