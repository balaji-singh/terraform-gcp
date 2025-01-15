output "custom_modules" {
  description = "Map of created custom security health analytics modules"
  value = {
    for k, v in google_scc_source.custom_module : k => {
      name         = v.name
      display_name = v.display_name
      description  = v.description
    }
  }
}

output "source_iam_bindings" {
  description = "Map of created IAM bindings for security sources"
  value = {
    for k, v in google_scc_source_iam_binding.source_iam : k => {
      source  = v.source
      role    = v.role
      members = v.members
    }
  }
}

output "notification_configs" {
  description = "Map of created notification configurations"
  value = {
    for k, v in google_scc_notification_config.notification : k => {
      name         = v.name
      description  = v.description
      pubsub_topic = v.pubsub_topic
    }
  }
}

output "mute_configs" {
  description = "Map of created mute configurations"
  value = {
    for k, v in google_scc_mute_config.mute_config : k => {
      name        = v.name
      description = v.description
      filter      = v.filter
    }
  }
}

output "findings" {
  description = "Map of created findings"
  value = {
    for k, v in google_scc_finding.finding : k => {
      name          = v.name
      state         = v.state
      category      = v.category
      severity      = v.severity
      resource_name = v.resource_name
    }
  }
}
