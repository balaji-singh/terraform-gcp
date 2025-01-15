output "brand" {
  description = "The created OAuth brand"
  value = var.create_brand ? {
    name            = google_iap_brand.brand[0].name
    support_email   = google_iap_brand.brand[0].support_email
    application_title = google_iap_brand.brand[0].application_title
  } : null
}

output "oauth_clients" {
  description = "Map of created OAuth clients"
  value = {
    for k, v in google_iap_client.client : k => {
      name          = v.name
      display_name  = v.display_name
      client_id     = v.client_id
      secret       = v.secret
    }
  }
  sensitive = true
}

output "backend_service_bindings" {
  description = "Map of backend service IAM bindings"
  value = {
    for k, v in google_iap_web_backend_service_iam_binding.backend_service_bindings : k => {
      role    = v.role
      members = v.members
    }
  }
}

output "web_bindings" {
  description = "Map of web IAM bindings"
  value = {
    for k, v in google_iap_web_iam_binding.web_bindings : k => {
      role    = v.role
      members = v.members
    }
  }
}

output "app_engine_bindings" {
  description = "Map of App Engine IAM bindings"
  value = {
    for k, v in google_iap_web_type_app_engine_iam_binding.app_engine_bindings : k => {
      app_id  = v.app_id
      role    = v.role
      members = v.members
    }
  }
}

output "compute_bindings" {
  description = "Map of Compute Engine IAM bindings"
  value = {
    for k, v in google_iap_web_type_compute_iam_binding.compute_bindings : k => {
      role    = v.role
      members = v.members
    }
  }
}

output "tunnel_instance_bindings" {
  description = "Map of tunnel instance IAM bindings"
  value = {
    for k, v in google_iap_tunnel_instance_iam_binding.tunnel_instance_bindings : k => {
      zone     = v.zone
      instance = v.instance
      role     = v.role
      members  = v.members
    }
  }
}

output "backend_service_configs" {
  description = "Map of backend service configurations"
  value = {
    for k, v in google_iap_web_backend_service_config.backend_service_config : k => {
      web_backend_service = v.web_backend_service
    }
  }
}
