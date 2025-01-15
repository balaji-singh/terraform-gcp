output "project_audit_configs" {
  description = "Map of created project-level audit configurations"
  value = {
    for k, v in google_project_iam_audit_config.project_audit_logs : k => {
      service = v.service
    }
  }
}

output "organization_audit_configs" {
  description = "Map of created organization-level audit configurations"
  value = {
    for k, v in google_organization_iam_audit_config.org_audit_logs : k => {
      service = v.service
    }
  }
}

output "folder_audit_configs" {
  description = "Map of created folder-level audit configurations"
  value = {
    for k, v in google_folder_iam_audit_config.folder_audit_logs : k => {
      folder  = v.folder
      service = v.service
    }
  }
}

output "project_sinks" {
  description = "Map of created logging sinks"
  value = {
    for k, v in google_logging_project_sink.project_sink : k => {
      name        = v.name
      destination = v.destination
      filter      = v.filter
      writer_identity = v.writer_identity
    }
  }
}

output "logging_metrics" {
  description = "Map of created logging metrics"
  value = {
    for k, v in google_logging_metric.logging_metric : k => {
      name        = v.name
      filter      = v.filter
      description = v.description
    }
  }
}

output "logging_buckets" {
  description = "Map of created logging buckets"
  value = {
    for k, v in google_logging_project_bucket_config.logging_bucket : k => {
      name            = v.name
      location        = v.location
      retention_days = v.retention_days
    }
  }
}
