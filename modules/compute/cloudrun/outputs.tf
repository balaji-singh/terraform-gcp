output "service_name" {
  description = "The name of the service"
  value       = google_cloud_run_v2_service.service.name
}

output "service_url" {
  description = "The URL on which the deployed service is available"
  value       = google_cloud_run_v2_service.service.uri
}

output "latest_revision_name" {
  description = "The name of the latest revision for this service"
  value       = google_cloud_run_v2_service.service.latest_revision
}

output "location" {
  description = "Location of the service"
  value       = google_cloud_run_v2_service.service.location
}

output "service_status" {
  description = "Status of the service"
  value       = google_cloud_run_v2_service.service.status
}

output "template" {
  description = "The template used for the service"
  value       = google_cloud_run_v2_service.service.template
  sensitive   = true
}
