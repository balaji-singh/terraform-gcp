output "vpc_sc_perimeters" {
  description = "Created VPC Service Control perimeters"
  value = module.vpc_sc.service_perimeters
}

output "binary_auth_policy" {
  description = "Created Binary Authorization policy"
  value = module.binary_auth.policy_config
}

output "audit_log_sinks" {
  description = "Created audit log sinks"
  value = module.audit_logs.log_sinks
}

output "security_center_configs" {
  description = "Security Command Center configurations"
  value = {
    notification_configs = module.security_center.notification_configs
    security_sources    = module.security_center.security_sources
  }
}

output "iam_configuration" {
  description = "IAM configuration details"
  value = {
    custom_roles      = module.strict_iam.custom_roles
    service_accounts  = module.strict_iam.service_accounts
    bindings         = module.strict_iam.bindings
  }
  sensitive = true
}

output "kms_keys" {
  description = "Created KMS keys"
  value = {
    key_rings    = module.kms.key_rings
    crypto_keys  = module.kms.crypto_keys
  }
  sensitive = true
}

output "security_scan_configs" {
  description = "Security Scanner configurations"
  value = module.security_scanner.scan_configs
}

output "asset_feeds" {
  description = "Asset Inventory feed configurations"
  value = module.asset_inventory.feed_config
}

output "security_status" {
  description = "Overall security status and compliance"
  value = {
    vpc_sc_enabled = true
    binary_auth_enabled = true
    audit_logging_enabled = true
    security_center_enabled = true
    kms_enabled = true
    security_scanning_enabled = true
    asset_tracking_enabled = true
    compliance_standards = var.compliance_standards
  }
}
