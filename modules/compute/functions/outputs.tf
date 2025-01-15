output "function_name" {
  description = "The name of the cloud function"
  value       = google_cloudfunctions2_function.function.name
}

output "function_uri" {
  description = "The URI of the cloud function"
  value       = google_cloudfunctions2_function.function.service_config[0].uri
}

output "state" {
  description = "Status of the cloud function"
  value       = google_cloudfunctions2_function.function.state
}

output "build_config" {
  description = "Build configuration of the function"
  value       = google_cloudfunctions2_function.function.build_config
}

output "service_config" {
  description = "Service configuration of the function"
  value       = google_cloudfunctions2_function.function.service_config
}

output "event_trigger" {
  description = "Event trigger configuration"
  value       = google_cloudfunctions2_function.function.event_trigger
}

output "source_bucket" {
  description = "The bucket containing the function source"
  value       = var.create_bucket ? google_storage_bucket.function_bucket[0].name : var.bucket_name
}

output "source_object" {
  description = "The object containing the function source"
  value       = google_storage_bucket_object.function_source.name
}
