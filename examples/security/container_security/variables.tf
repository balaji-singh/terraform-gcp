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
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

variable "service_account_email" {
  description = "Email of the service account"
  type        = string
}

variable "kms_key_name" {
  description = "Name of the KMS key for container registry encryption"
  type        = string
}

variable "notification_channels" {
  description = "List of notification channel IDs"
  type        = list(string)
  default     = []
}

variable "authorized_networks" {
  description = "List of authorized networks for GKE master"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "gke_config" {
  description = "GKE cluster configuration"
  type = object({
    node_pools = map(object({
      machine_type = string
      disk_size_gb = number
      disk_type    = string
      image_type   = string
      auto_repair  = bool
      auto_upgrade = bool
      min_count    = number
      max_count    = number
    }))
    master_authorized_networks_enabled = bool
    network_policy_enabled = bool
    pod_security_policy_enabled = bool
    private_cluster_enabled = bool
    enable_shielded_nodes = bool
    enable_workload_identity = bool
  })
  default = {
    node_pools = {
      default = {
        machine_type = "e2-standard-2"
        disk_size_gb = 100
        disk_type    = "pd-standard"
        image_type   = "COS_CONTAINERD"
        auto_repair  = true
        auto_upgrade = true
        min_count    = 1
        max_count    = 3
      }
    }
    master_authorized_networks_enabled = true
    network_policy_enabled = true
    pod_security_policy_enabled = true
    private_cluster_enabled = true
    enable_shielded_nodes = true
    enable_workload_identity = true
  }
}

variable "binary_authorization_config" {
  description = "Binary Authorization configuration"
  type = object({
    evaluation_mode = string
    default_admission_rule = object({
      evaluation_mode = string
      enforcement_mode = string
    })
    cluster_admission_rules = map(object({
      evaluation_mode = string
      enforcement_mode = string
    }))
  })
  default = {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
    default_admission_rule = {
      evaluation_mode = "REQUIRE_ATTESTATION"
      enforcement_mode = "ENFORCED_BLOCK_AND_AUDIT_LOG"
    }
    cluster_admission_rules = {}
  }
}

variable "container_registry_config" {
  description = "Container Registry configuration"
  type = object({
    location = string
    vulnerability_scanning = object({
      enabled = bool
      scan_frequency = string
    })
  })
  default = {
    location = "us"
    vulnerability_scanning = {
      enabled = true
      scan_frequency = "DAILY"
    }
  }
}

variable "pod_security_config" {
  description = "Pod Security Standards configuration"
  type = map(object({
    enforcement = string
    severity = string
    parameters = map(bool)
  }))
  default = {
    restricted = {
      enforcement = "enforcing"
      severity = "high"
      parameters = {
        hostNetwork = false
        hostPID = false
        hostIPC = false
        privileged = false
        allowPrivilegeEscalation = false
        readOnlyRootFilesystem = true
      }
    }
  }
}

variable "network_policy_config" {
  description = "Network Policy configuration"
  type = map(object({
    namespace = string
    pod_selector = map(any)
    policy_types = list(string)
    ingress = optional(list(object({
      from = list(object({
        namespace_selector = optional(map(any))
        pod_selector = optional(map(any))
      }))
    })))
    egress = optional(list(object({
      to = list(object({
        namespace_selector = optional(map(any))
        pod_selector = optional(map(any))
      }))
    })))
  }))
  default = {}
}

variable "monitoring_config" {
  description = "Container monitoring configuration"
  type = object({
    alert_thresholds = map(number)
    evaluation_periods = map(string)
  })
  default = {
    alert_thresholds = {
      vulnerability_count = 0
      policy_violation_count = 0
    }
    evaluation_periods = {
      vulnerability = "0s"
      policy_violation = "0s"
    }
  }
}

variable "compliance_requirements" {
  description = "Compliance requirements for container security"
  type = map(object({
    enabled = bool
    controls = list(string)
  }))
  default = {
    pci_dss = {
      enabled = true
      controls = [
        "container_hardening",
        "vulnerability_scanning",
        "access_control"
      ]
    }
    hipaa = {
      enabled = true
      controls = [
        "encryption",
        "audit_logging",
        "network_isolation"
      ]
    }
  }
}
