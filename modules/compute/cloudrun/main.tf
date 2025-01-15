/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 */

resource "google_cloud_run_v2_service" "service" {
  name     = var.service_name
  location = var.location
  project  = var.project_id

  template {
    containers {
      image = var.container_image

      resources {
        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
        }
        cpu_idle = var.cpu_idle
      }

      ports {
        container_port = var.container_port
      }

      dynamic "env" {
        for_each = var.environment_variables
        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "volume_mounts" {
        for_each = var.volume_mounts
        content {
          name       = volume_mounts.value.name
          mount_path = volume_mounts.value.mount_path
        }
      }
    }

    dynamic "volumes" {
      for_each = var.volumes
      content {
        name = volumes.value.name
        secret {
          secret       = volumes.value.secret_name
          default_mode = volumes.value.default_mode
          items {
            path    = volumes.value.path
            version = volumes.value.version
            mode    = volumes.value.mode
          }
        }
      }
    }

    service_account = var.service_account_email
    timeout_seconds = var.timeout_seconds

    max_instance_request_concurrency = var.max_instance_request_concurrency
    execution_environment           = var.execution_environment
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
}
