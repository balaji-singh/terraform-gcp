/**
 * Comprehensive Security Composition
 * This composition combines all security modules for maximum protection
 */

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Network Security Layer
module "network_security" {
  source = "../../../modules/security/network"

  project_id = var.project_id
  network_name = var.network_name

  subnets = var.subnet_config
  firewall_rules = var.firewall_rules
}

# Cloud Armor Security
module "cloud_armor" {
  source = "../../../modules/security/cloud_armor"

  project_id = var.project_id
  security_policies = var.security_policies
}

# Identity and Access Management
module "iam_security" {
  source = "../../../modules/security/iam"

  project_id = var.project_id
  service_accounts = var.service_accounts
  custom_roles = var.custom_roles
  bindings = var.iam_bindings
}

# Key Management Service
module "kms_security" {
  source = "../../../modules/security/kms"

  project_id = var.project_id
  location = var.region
  key_rings = var.key_rings
  crypto_keys = var.crypto_keys
}

# Container Security
module "container_security" {
  source = "../../../modules/security/container"

  project_id = var.project_id
  location = var.region
  cluster_config = var.cluster_config
  registry_config = var.registry_config
}

# Binary Authorization
module "binary_auth" {
  source = "../../../modules/security/binary_authorization"

  project_id = var.project_id
  policy_config = var.binary_auth_config
}

# Security Command Center
module "security_center" {
  source = "../../../modules/security/security_center"

  organization_id = var.organization_id
  project_id = var.project_id
  notification_configs = var.notification_configs
  security_findings = var.security_findings
}

# Cloud DLP
module "dlp_security" {
  source = "../../../modules/security/dlp"

  project_id = var.project_id
  inspect_templates = var.inspect_templates
  deidentify_templates = var.deidentify_templates
}

# VPC Service Controls
module "vpc_sc" {
  source = "../../../modules/security/vpc_sc"

  organization_id = var.organization_id
  project_id = var.project_id
  access_policy = var.access_policy
  service_perimeters = var.service_perimeters
}

# Asset Inventory
module "asset_inventory" {
  source = "../../../modules/security/asset_inventory"

  project_id = var.project_id
  feed_config = var.asset_feed_config
}

# Cloud Audit Logs
module "audit_logs" {
  source = "../../../modules/security/audit_logs"

  project_id = var.project_id
  audit_log_config = var.audit_log_config
  log_sinks = var.log_sinks
}

# Security Scanner
module "security_scanner" {
  source = "../../../modules/security/security_scanner"

  project_id = var.project_id
  scan_configs = var.scan_configs
}

# Secret Manager
module "secret_manager" {
  source = "../../../modules/security/secrets"

  project_id = var.project_id
  secrets = var.secrets
}

# Identity-Aware Proxy
module "iap" {
  source = "../../../modules/security/iap"

  project_id = var.project_id
  tunnel_instances = var.iap_tunnels
  bindings = var.iap_bindings
}

# Security Health Analytics
module "security_health" {
  source = "../../../modules/security/health_analytics"

  project_id = var.project_id
  organization_id = var.organization_id
  custom_modules = var.health_modules
}

# Security Monitoring
module "security_monitoring" {
  source = "../../../modules/security/monitoring"

  project_id = var.project_id
  alert_policies = var.alert_policies
  notification_channels = var.notification_channels
}

# Web Security Scanner
module "web_security" {
  source = "../../../modules/security/web_security"

  project_id = var.project_id
  scan_configs = var.web_scan_configs
}

# Container Analysis
module "container_analysis" {
  source = "../../../modules/security/container_analysis"

  project_id = var.project_id
  notes = var.container_notes
  occurrences = var.container_occurrences
}

# Cloud NAT
module "cloud_nat" {
  source = "../../../modules/security/cloud_nat"

  project_id = var.project_id
  region = var.region
  network = module.network_security.network.name
  nat_configs = var.nat_configs
}

# Private Service Connect
module "private_connect" {
  source = "../../../modules/security/private_connect"

  project_id = var.project_id
  network = module.network_security.network.name
  service_connections = var.service_connections
}

# SSL Policy
module "ssl_policy" {
  source = "../../../modules/security/ssl_policy"

  project_id = var.project_id
  policies = var.ssl_policies
}

# Network Policy
module "network_policy" {
  source = "../../../modules/security/network_policy"

  project_id = var.project_id
  cluster_name = module.container_security.cluster_name
  location = var.region
  policies = var.network_policies
}

# Pod Security
module "pod_security" {
  source = "../../../modules/security/pod_security"

  project_id = var.project_id
  cluster_name = module.container_security.cluster_name
  location = var.region
  policies = var.pod_security_policies
}

# VPC Flow Logs
module "flow_logs" {
  source = "../../../modules/security/vpc_flow_logs"

  project_id = var.project_id
  network = module.network_security.network.name
  flow_logs = var.flow_logs_config
}

# Workload Identity
module "workload_identity" {
  source = "../../../modules/security/workload_identity"

  project_id = var.project_id
  service_accounts = var.workload_service_accounts
  workload_identity_bindings = var.workload_identity_bindings
}

# Essential Contacts
module "essential_contacts" {
  source = "../../../modules/security/essential_contacts"

  project_id = var.project_id
  organization_id = var.organization_id
  contacts = var.essential_contacts
}

# Security Response
module "security_response" {
  source = "../../../modules/security/response"

  project_id = var.project_id
  incident_configs = var.incident_configs
  response_policies = var.response_policies
}

# Compliance Controls
module "compliance" {
  source = "../../../modules/security/compliance"

  project_id = var.project_id
  organization_id = var.organization_id
  compliance_frameworks = var.compliance_frameworks
  control_mappings = var.control_mappings
}
