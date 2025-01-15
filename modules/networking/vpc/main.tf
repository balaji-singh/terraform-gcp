/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 */

resource "google_compute_network" "vpc" {
  name                            = var.network_name
  project                         = var.project_id
  auto_create_subnetworks        = var.auto_create_subnetworks
  routing_mode                   = var.routing_mode
  delete_default_routes_on_create = var.delete_default_routes_on_create
  mtu                            = var.mtu
}

resource "google_compute_subnetwork" "subnetwork" {
  for_each = var.subnets

  name          = each.key
  project       = var.project_id
  network       = google_compute_network.vpc.self_link
  region        = each.value.region
  ip_cidr_range = each.value.ip_cidr_range

  private_ip_google_access = lookup(each.value, "private_ip_google_access", true)
  
  dynamic "secondary_ip_range" {
    for_each = lookup(each.value, "secondary_ip_ranges", {})
    content {
      range_name    = secondary_ip_range.key
      ip_cidr_range = secondary_ip_range.value
    }
  }

  log_config {
    aggregation_interval = lookup(each.value, "flow_logs_interval", "INTERVAL_5_SEC")
    flow_sampling       = lookup(each.value, "flow_logs_sampling", 0.5)
    metadata           = lookup(each.value, "flow_logs_metadata", "INCLUDE_ALL_METADATA")
  }
}

resource "google_compute_firewall" "allow_internal" {
  count   = var.create_internal_firewall ? 1 : 0
  name    = "${var.network_name}-allow-internal"
  project = var.project_id
  network = google_compute_network.vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [for subnet in google_compute_subnetwork.subnetwork : subnet.ip_cidr_range]
}

resource "google_compute_firewall" "allow_iap_ssh" {
  count   = var.create_iap_firewall ? 1 : 0
  name    = "${var.network_name}-allow-iap-ssh"
  project = var.project_id
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_route" "internet_route" {
  count            = var.create_internet_route ? 1 : 0
  name             = "${var.network_name}-internet-route"
  project          = var.project_id
  network          = google_compute_network.vpc.name
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
}

resource "google_compute_router" "router" {
  for_each = var.cloud_nat_configs

  name    = "${var.network_name}-${each.key}-router"
  project = var.project_id
  region  = each.key
  network = google_compute_network.vpc.name

  bgp {
    asn = each.value.router_asn
  }
}

resource "google_compute_router_nat" "nat" {
  for_each = var.cloud_nat_configs

  name                               = "${var.network_name}-${each.key}-nat"
  project                           = var.project_id
  router                            = google_compute_router.router[each.key].name
  region                            = each.key
  nat_ip_allocate_option            = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
