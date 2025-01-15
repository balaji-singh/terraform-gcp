output "organization_policies" {
  description = "Map of created organization-level policies"
  value = {
    for k, v in google_org_policy_policy.org_policy : k => {
      name   = v.name
      parent = v.parent
    }
  }
}

output "project_policies" {
  description = "Map of created project-level organization policies"
  value = {
    for k, v in google_project_organization_policy.project_policy : k => {
      project    = v.project
      constraint = v.constraint
    }
  }
}

output "folder_policies" {
  description = "Map of created folder-level organization policies"
  value = {
    for k, v in google_folder_organization_policy.folder_policy : k => {
      folder     = v.folder
      constraint = v.constraint
    }
  }
}
