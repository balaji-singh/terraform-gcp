output "org_policies" {
  description = "Created organization policies"
  value       = module.org_policy.organization_policies
}

output "security_scan_configs" {
  description = "Created security scan configurations"
  value       = module.security_scanner.scan_configs
}

output "security_health_modules" {
  description = "Created security health analytics modules"
  value       = module.security_health.custom_modules
}

output "audit_log_configs" {
  description = "Created audit log configurations"
  value       = module.audit_logs
  sensitive   = true
}

output "access_levels" {
  description = "Created access levels"
  value       = module.access_context.access_levels
}

output "binary_authorization_policy" {
  description = "Created binary authorization policy"
  value       = module.binary_authorization
}

output "asset_feeds" {
  description = "Created asset inventory feeds"
  value       = module.asset_inventory
}

output "iap_config" {
  description = "Created IAP configuration"
  value       = module.iap
  sensitive   = true
}
