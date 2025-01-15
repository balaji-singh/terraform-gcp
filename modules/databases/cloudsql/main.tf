/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 */

resource "google_sql_database_instance" "instance" {
  name             = var.instance_name
  database_version = var.database_version
  region           = var.region
  project          = var.project_id

  settings {
    tier              = var.tier
    availability_type = var.availability_type
    disk_size         = var.disk_size
    disk_type         = var.disk_type
    
    backup_configuration {
      enabled                        = var.backup_enabled
      binary_log_enabled            = var.binary_log_enabled
      start_time                    = var.backup_start_time
      transaction_log_retention_days = var.transaction_log_retention_days
      retained_backups              = var.retained_backups
      retention_unit                = "COUNT"
    }

    ip_configuration {
      ipv4_enabled       = var.public_ip_enabled
      private_network    = var.private_network
      require_ssl        = var.require_ssl
      
      dynamic "authorized_networks" {
        for_each = var.authorized_networks
        content {
          name  = authorized_networks.value.name
          value = authorized_networks.value.cidr
        }
      }
    }

    database_flags {
      name  = "max_connections"
      value = var.max_connections
    }

    maintenance_window {
      day          = var.maintenance_window_day
      hour         = var.maintenance_window_hour
      update_track = var.maintenance_window_update_track
    }

    insights_config {
      query_insights_enabled  = var.query_insights_enabled
      query_string_length    = var.query_string_length
      record_application_tags = var.record_application_tags
      record_client_address  = var.record_client_address
    }
  }

  deletion_protection = var.deletion_protection

  depends_on = [var.module_depends_on]
}

resource "google_sql_database" "database" {
  for_each = toset(var.databases)
  
  name      = each.value
  instance  = google_sql_database_instance.instance.name
  charset   = var.db_charset
  collation = var.db_collation
  project   = var.project_id
}

resource "google_sql_user" "users" {
  for_each = { for user in var.users : user.name => user }
  
  name     = each.value.name
  instance = google_sql_database_instance.instance.name
  password = each.value.password
  project  = var.project_id

  deletion_policy = "ABANDON"
}
