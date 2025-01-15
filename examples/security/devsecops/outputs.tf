output "build_trigger" {
  description = "Created Cloud Build trigger"
  value       = module.secure_build.triggers
}

output "binary_auth_policy" {
  description = "Created Binary Authorization policy"
  value       = module.binary_auth.policy_config
}

output "container_analysis_notes" {
  description = "Created Container Analysis notes"
  value       = module.container_analysis.notes
}

output "pipeline_secrets" {
  description = "Created pipeline secrets"
  value = {
    for k, v in module.pipeline_secrets.secrets : k => {
      name = v.name
      replication = v.replication
    }
  }
  sensitive = true
}

output "pipeline_service_account" {
  description = "Created pipeline service account"
  value       = module.pipeline_iam.service_accounts["pipeline-sa"]
}

output "artifact_scan_config" {
  description = "Created artifact scan configuration"
  value       = module.artifact_scanner.scan_configs
}

output "audit_config" {
  description = "Created audit configuration"
  value       = module.pipeline_audit.audit_log_config
}

output "security_notifications" {
  description = "Created security notification configurations"
  value       = module.pipeline_security_center.notification_configs
}

output "kms_keys" {
  description = "Created KMS keys"
  value = {
    key_rings = module.pipeline_kms.key_rings
    crypto_keys = module.pipeline_kms.crypto_keys
  }
  sensitive = true
}

output "pipeline_security_status" {
  description = "Overall pipeline security status"
  value = {
    binary_authorization_enabled = true
    vulnerability_scanning_enabled = true
    secret_management_enabled = true
    audit_logging_enabled = true
    security_notifications_enabled = true
    artifact_signing_enabled = true
    compliance_standards = var.compliance_standards
  }
}

output "security_controls" {
  description = "Enabled security controls"
  value = {
    vulnerability_scanning = var.security_controls.require_vulnerability_scanning
    attestation = var.security_controls.require_attestation
    security_reviews = var.security_controls.require_security_reviews
    severity_blocking = var.security_controls.block_on_high_severity
  }
}
