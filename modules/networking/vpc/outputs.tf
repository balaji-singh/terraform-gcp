output "network" {
  description = "The created network"
  value       = google_compute_network.vpc
}

output "network_name" {
  description = "The name of the VPC being created"
  value       = google_compute_network.vpc.name
}

output "network_id" {
  description = "The ID of the VPC being created"
  value       = google_compute_network.vpc.id
}

output "network_self_link" {
  description = "The URI of the VPC being created"
  value       = google_compute_network.vpc.self_link
}

output "subnets" {
  description = "A map of subnetwork objects"
  value       = google_compute_subnetwork.subnetwork
}

output "subnets_names" {
  description = "The names of the subnets being created"
  value       = [for subnet in google_compute_subnetwork.subnetwork : subnet.name]
}

output "subnets_regions" {
  description = "The regions where subnets are being created"
  value       = [for subnet in google_compute_subnetwork.subnetwork : subnet.region]
}

output "subnets_ips" {
  description = "The IPs and CIDRs of the subnets being created"
  value       = [for subnet in google_compute_subnetwork.subnetwork : subnet.ip_cidr_range]
}

output "subnets_secondary_ranges" {
  description = "The secondary ranges associated with these subnets"
  value       = { for subnet in google_compute_subnetwork.subnetwork : subnet.name => subnet.secondary_ip_range }
}

output "router_names" {
  description = "The names of the routers created"
  value       = [for router in google_compute_router.router : router.name]
}

output "nat_names" {
  description = "The names of the Cloud NAT instances created"
  value       = [for nat in google_compute_router_nat.nat : nat.name]
}
