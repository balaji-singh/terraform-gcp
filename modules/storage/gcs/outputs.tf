output "bucket" {
  description = "The created storage bucket"
  value       = google_storage_bucket.bucket
}

output "name" {
  description = "The name of the bucket"
  value       = google_storage_bucket.bucket.name
}

output "url" {
  description = "The base URL of the bucket, in the format gs://<bucket-name>"
  value       = google_storage_bucket.bucket.url
}

output "self_link" {
  description = "The URI of the created resource"
  value       = google_storage_bucket.bucket.self_link
}

output "location" {
  description = "The location of the bucket"
  value       = google_storage_bucket.bucket.location
}
