include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/security/audit_logs"
}

dependency "storage" {
  config_path = "../storage"
}

inputs = {
  audit_log_config = {
    service = "allServices"
    audit_log_configs = {
      log_type = "DATA_READ,DATA_WRITE,ADMIN_READ"
      exempted_members = []
    }
  }

  log_sinks = {
    "security-audit-logs" = {
      destination = "storage.googleapis.com/${dependency.storage.outputs.bucket_name}"
      filter = "resource.type=gcs_bucket OR resource.type=bigquery_resource"
      unique_writer_identity = true
    }
  }
}
