output "secrets" {
  description = "Map of created secrets"
  value = {
    for k, v in google_secret_manager_secret.secrets : k => {
      id            = v.id
      name          = v.name
      create_time   = v.create_time
      labels        = v.labels
      expire_time   = v.expire_time
      version_count = length(v.version_aliases)
    }
  }
}

output "versions" {
  description = "Map of created secret versions"
  value = {
    for k, v in google_secret_manager_secret_version.versions : k => {
      id          = v.id
      name        = v.name
      create_time = v.create_time
      enabled     = v.enabled
      state       = v.state
    }
  }
  sensitive = true
}

output "iam_bindings" {
  description = "Map of IAM bindings for secrets"
  value = {
    for k, v in google_secret_manager_secret_iam_binding.bindings : k => {
      secret_id = v.secret_id
      role      = v.role
      members   = v.members
    }
  }
}
