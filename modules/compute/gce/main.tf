/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 */

resource "google_compute_instance" "default" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = var.boot_disk_size_gb
      type  = var.boot_disk_type
    }
  }

  network_interface {
    network = var.network
    subnetwork = var.subnetwork

    dynamic "access_config" {
      for_each = var.enable_public_ip ? [1] : []
      content {
        // Ephemeral public IP
      }
    }
  }

  metadata = var.metadata

  tags = var.network_tags

  service_account {
    email  = var.service_account_email
    scopes = var.service_account_scopes
  }

  allow_stopping_for_update = true

  labels = var.labels
}
