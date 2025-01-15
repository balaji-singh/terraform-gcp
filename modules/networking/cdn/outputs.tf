output "backend_bucket_name" {
  description = "The name of the backend bucket"
  value       = google_compute_backend_bucket.cdn_backend.name
}

output "backend_bucket_self_link" {
  description = "The URI of the created backend bucket"
  value       = google_compute_backend_bucket.cdn_backend.self_link
}

output "storage_bucket_name" {
  description = "The name of the storage bucket"
  value       = google_storage_bucket.cdn_bucket.name
}

output "storage_bucket_url" {
  description = "The base URL of the bucket, in the format gs://<bucket-name>"
  value       = google_storage_bucket.cdn_bucket.url
}

output "cdn_url_map_name" {
  description = "Name of the URL map"
  value       = google_compute_url_map.cdn_url_map.name
}

output "cdn_url_map_self_link" {
  description = "The URI of the created URL map"
  value       = google_compute_url_map.cdn_url_map.self_link
}

output "cdn_ip_address" {
  description = "The IP address of the CDN"
  value       = var.create_ip ? google_compute_global_address.cdn_ip[0].address : var.ip_address
}

output "forwarding_rule_name" {
  description = "The name of the forwarding rule"
  value       = google_compute_global_forwarding_rule.cdn_forwarding_rule.name
}

output "forwarding_rule_self_link" {
  description = "The URI of the created forwarding rule"
  value       = google_compute_global_forwarding_rule.cdn_forwarding_rule.self_link
}
