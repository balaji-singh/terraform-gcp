output "organization_feeds" {
  description = "Map of created organization-level asset feeds"
  value = {
    for k, v in google_cloud_asset_organization_feed.organization_feed : k => {
      name         = v.name
      content_type = v.content_type
      asset_types  = v.asset_types
    }
  }
}

output "folder_feeds" {
  description = "Map of created folder-level asset feeds"
  value = {
    for k, v in google_cloud_asset_folder_feed.folder_feed : k => {
      name         = v.name
      folder       = v.folder
      content_type = v.content_type
      asset_types  = v.asset_types
    }
  }
}

output "project_feeds" {
  description = "Map of created project-level asset feeds"
  value = {
    for k, v in google_cloud_asset_project_feed.project_feed : k => {
      name         = v.name
      content_type = v.content_type
      asset_types  = v.asset_types
    }
  }
}

output "organization_saved_queries" {
  description = "Map of created organization-level saved queries"
  value = {
    for k, v in google_cloud_asset_organization_saved_query.organization_query : k => {
      name        = v.name
      query_id    = v.query_id
      description = v.description
    }
  }
}

output "project_saved_queries" {
  description = "Map of created project-level saved queries"
  value = {
    for k, v in google_cloud_asset_project_saved_query.project_query : k => {
      name        = v.name
      query_id    = v.query_id
      description = v.description
    }
  }
}

output "feed_iam_bindings" {
  description = "Map of created IAM bindings for asset feeds"
  value = {
    for k, v in google_cloud_asset_feed_iam_binding.feed_iam : k => {
      feed    = v.feed
      role    = v.role
      members = v.members
    }
  }
}
