output "forwarding_rule" {
  description = "The forwarding rule"
  value       = google_compute_global_forwarding_rule.default
}

output "external_ip" {
  description = "The external IP address of the load balancer"
  value       = var.create_address ? google_compute_global_address.default[0].address : var.address
}

output "backend_service" {
  description = "The backend service"
  value       = google_compute_backend_service.default
}

output "url_map" {
  description = "The URL map"
  value       = google_compute_url_map.default
}

output "http_proxy" {
  description = "The HTTP proxy"
  value       = google_compute_target_http_proxy.default
}

output "health_check" {
  description = "The health check resource"
  value       = google_compute_health_check.default
}

output "additional_backend_services" {
  description = "Map of additional backend services created"
  value       = google_compute_backend_service.services
}
