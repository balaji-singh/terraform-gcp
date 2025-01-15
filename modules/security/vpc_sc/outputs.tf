output "access_policy" {
  description = "The created access policy"
  value = var.create_access_policy ? {
    id     = google_access_context_manager_access_policy.policy[0].name
    title  = google_access_context_manager_access_policy.policy[0].title
    parent = google_access_context_manager_access_policy.policy[0].parent
    scopes = google_access_context_manager_access_policy.policy[0].scopes
  } : null
}

output "access_levels" {
  description = "Map of created access levels"
  value = {
    for k, v in google_access_context_manager_access_level.levels : k => {
      name   = v.name
      title  = v.title
      parent = v.parent
    }
  }
}

output "service_perimeters" {
  description = "Map of created service perimeters"
  value = {
    for k, v in google_access_context_manager_service_perimeter.regular : k => {
      name            = v.name
      title           = v.title
      perimeter_type  = v.perimeter_type
      parent          = v.parent
      create_time     = v.create_time
      update_time     = v.update_time
    }
  }
}
