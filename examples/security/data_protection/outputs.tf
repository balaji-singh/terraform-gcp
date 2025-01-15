output "kms_keys" {
  description = "Created KMS keys for data protection"
  value = {
    key_rings = module.data_encryption.key_rings
    crypto_keys = module.data_encryption.crypto_keys
  }
  sensitive = true
}

output "dlp_templates" {
  description = "Created DLP templates"
  value = {
    inspect_templates = module.dlp.inspect_templates
    deidentify_templates = module.dlp.deidentify_templates
  }
}

output "vpc_sc_perimeters" {
  description = "Created VPC Service Control perimeters"
  value = module.data_vpc_sc.service_perimeters
}

output "iam_configuration" {
  description = "IAM configuration for data access"
  value = {
    custom_roles = module.data_access_iam.custom_roles
    bindings = module.data_access_iam.bindings
  }
  sensitive = true
}

output "audit_configuration" {
  description = "Audit logging configuration"
  value = {
    log_config = module.data_audit.audit_log_config
    log_sinks = module.data_audit.log_sinks
  }
}

output "security_notifications" {
  description = "Security notification configurations"
  value = module.data_security_center.notification_configs
}

output "asset_inventory" {
  description = "Asset inventory configuration"
  value = module.data_assets.feed_config
}

output "data_protection_status" {
  description = "Overall data protection status"
  value = {
    encryption_enabled = true
    dlp_enabled = true
    vpc_sc_enabled = true
    audit_logging_enabled = true
    security_monitoring_enabled = true
    asset_tracking_enabled = true
    compliance_status = {
      for standard, config in var.compliance_requirements : standard => {
        enabled = config.enabled
        controls_implemented = config.controls
      }
    }
  }
}

output "data_classification_status" {
  description = "Data classification implementation status"
  value = {
    for level, config in var.data_classification : level => {
      controls_implemented = {
        encryption = config.encryption_required
        audit_logging = config.audit_required
        dlp = config.dlp_required
        vpc_sc = config.vpc_sc_required
        access_approval = config.access_approval_required
      }
    }
  }
}

output "security_controls" {
  description = "Implemented security controls"
  value = {
    encryption = {
      customer_managed_keys = true
      hsm_protection = true
      key_rotation_enabled = true
    }
    data_discovery = {
      dlp_scanning = true
      classification_enabled = true
    }
    access_control = {
      vpc_sc_enabled = true
      iam_conditions = true
    }
    monitoring = {
      audit_logging = true
      security_alerts = true
      asset_tracking = true
    }
  }
}
