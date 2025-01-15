output "scan_configs" {
  description = "Map of created scan configurations"
  value = {
    for k, v in google_security_scanner_scan_config.scan_config : k => {
      name            = v.name
      display_name    = v.display_name
      starting_urls   = v.starting_urls
      target_platforms = v.target_platforms
    }
  }
}

output "scan_runs" {
  description = "Map of created scan runs"
  value = {
    for k, v in google_security_scanner_scan_run.scan_run : k => {
      name            = v.name
      scan_config     = v.scan_config
      execution_state = v.execution_state
    }
  }
}

output "scan_config_iam_bindings" {
  description = "Map of created IAM bindings for scan configurations"
  value = {
    for k, v in google_security_scanner_scan_config_iam_binding.scan_config_iam : k => {
      scan_config = v.scan_config
      role        = v.role
      members     = v.members
    }
  }
}
