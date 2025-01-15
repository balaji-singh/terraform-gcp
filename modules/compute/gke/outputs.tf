output "cluster_id" {
  description = "The unique identifier of the cluster"
  value       = google_container_cluster.primary.id
}

output "cluster_name" {
  description = "The name of the cluster"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "The IP address of the cluster master"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "The public certificate that is the root of trust for the cluster"
  value       = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  sensitive   = true
}

output "node_pools" {
  description = "List of node pools associated with this cluster"
  value       = google_container_node_pool.primary_nodes.name
}

output "location" {
  description = "The location of the cluster"
  value       = google_container_cluster.primary.location
}
