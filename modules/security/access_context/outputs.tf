output "access_policy" {
  description = "The created access policy"
  value = var.create_access_policy ? {
    id     = google_access_context_manager_access_policy.policy[0].name
    title  = google_access_context_manager_access_policy.policy[0].title
    parent = google_access_context_manager_access_policy.policy[0].parent
    scopes = google_access_context_manager_access_policy.policy[0].scopes
  } : null
}

output "custom_access_levels" {
  description = "Map of created custom access levels"
  value = {
    for k, v in google_access_context_manager_access_level.custom : k => {
      name   = v.name
      title  = v.title
      parent = v.parent
    }
  }
}

output "gcp_user_access_bindings" {
  description = "Map of created GCP user access bindings"
  value = {
    for k, v in google_access_context_manager_gcp_user_access_binding.binding : k => {
      organization_id = v.organization_id
      group_key      = v.group_key
      access_levels  = v.access_levels
    }
  }
}

output "service_perimeter_bridges" {
  description = "Map of created service perimeter bridges"
  value = {
    for k, v in google_access_context_manager_service_perimeter_resource.bridge : k => {
      perimeter_name = v.perimeter_name
      resource      = v.resource
    }
  }
}

output "access_policy_iam_bindings" {
  description = "Map of created IAM bindings for access policy"
  value = {
    for k, v in google_access_context_manager_access_policy_iam_binding.policy_iam : k => {
      role    = v.role
      members = v.members
    }
  }
}
