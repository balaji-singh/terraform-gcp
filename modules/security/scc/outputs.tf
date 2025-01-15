output "organization_settings" {
  description = "The organization settings"
  value = var.enable_organization_settings ? {
    name                   = google_scc_organization_settings.organization_settings[0].name
    enable_asset_discovery = google_scc_organization_settings.organization_settings[0].enable_asset_discovery
  } : null
}

output "sources" {
  description = "Map of created sources"
  value = {
    for k, v in google_scc_source.sources : k => {
      name         = v.name
      display_name = v.display_name
      description  = v.description
    }
  }
}

output "notification_configs" {
  description = "Map of created notification configs"
  value = {
    for k, v in google_scc_notification_config.notification_configs : k => {
      name         = v.name
      description  = v.description
      pubsub_topic = v.pubsub_topic
    }
  }
}

output "findings" {
  description = "Map of created findings"
  value = {
    for k, v in google_scc_finding.findings : k => {
      name           = v.name
      state          = v.state
      category       = v.category
      severity       = v.severity
      resource_name  = v.resource_name
    }
  }
}

output "mute_configs" {
  description = "Map of created mute configs"
  value = {
    for k, v in google_scc_mute_config.mute_configs : k => {
      name        = v.name
      filter      = v.filter
      description = v.description
    }
  }
}

output "custom_modules" {
  description = "Map of created custom modules"
  value = {
    for k, v in google_scc_security_health_analytics_custom_module.custom_modules : k => {
      name            = v.name
      display_name    = v.display_name
      enablement_state = v.enablement_state
    }
  }
}
