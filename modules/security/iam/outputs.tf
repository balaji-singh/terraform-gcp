output "service_accounts" {
  description = "Map of created service accounts"
  value = {
    for k, v in google_service_account.service_accounts : k => {
      email        = v.email
      account_id   = v.account_id
      name         = v.name
      display_name = v.display_name
      unique_id    = v.unique_id
    }
  }
}

output "service_account_keys" {
  description = "Map of created service account keys"
  value = {
    for k, v in google_service_account_key.keys : k => {
      name            = v.name
      public_key      = v.public_key
      private_key     = v.private_key
      valid_after    = v.valid_after
      valid_before   = v.valid_before
    }
  }
  sensitive = true
}

output "custom_roles" {
  description = "Map of created custom roles"
  value = {
    for k, v in google_project_iam_custom_role.custom_roles : k => {
      role_id     = v.role_id
      title       = v.title
      description = v.description
      permissions = v.permissions
      stage       = v.stage
    }
  }
}

output "workload_identity_pools" {
  description = "Map of created workload identity pools"
  value = {
    for k, v in google_iam_workload_identity_pool.pools : k => {
      name         = v.name
      display_name = v.display_name
      state        = v.state
    }
  }
}

output "workload_identity_pool_providers" {
  description = "Map of created workload identity pool providers"
  value = {
    for k, v in google_iam_workload_identity_pool_provider.pool_providers : k => {
      name         = v.name
      display_name = v.display_name
      state        = v.state
    }
  }
}
