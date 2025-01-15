output "instance_name" {
  description = "The name of the database instance"
  value       = google_sql_database_instance.instance.name
}

output "instance_connection_name" {
  description = "The connection name of the instance to be used in connection strings"
  value       = google_sql_database_instance.instance.connection_name
}

output "instance_self_link" {
  description = "The URI of the instance"
  value       = google_sql_database_instance.instance.self_link
}

output "instance_service_account_email_address" {
  description = "The service account email address assigned to the instance"
  value       = google_sql_database_instance.instance.service_account_email_address
}

output "private_ip_address" {
  description = "The private IP address assigned for the master instance"
  value       = google_sql_database_instance.instance.private_ip_address
}

output "public_ip_address" {
  description = "The public IP address assigned for the master instance"
  value       = google_sql_database_instance.instance.public_ip_address
}

output "databases" {
  description = "List of databases created"
  value       = [for db in google_sql_database.database : db.name]
}

output "users" {
  description = "List of users created"
  value       = [for user in google_sql_user.users : user.name]
  sensitive   = true
}
