output "instance_id" {
  description = "The server-assigned unique identifier of this instance"
  value       = google_compute_instance.default.instance_id
}

output "instance_name" {
  description = "The name of the instance"
  value       = google_compute_instance.default.name
}

output "instance_self_link" {
  description = "The URI of the created instance"
  value       = google_compute_instance.default.self_link
}

output "internal_ip" {
  description = "The internal IP address of the instance"
  value       = google_compute_instance.default.network_interface[0].network_ip
}

output "external_ip" {
  description = "The external IP address of the instance (if enabled)"
  value       = var.enable_public_ip ? google_compute_instance.default.network_interface[0].access_config[0].nat_ip : null
}
