output "zone_id" {
  description = "The ID of the zone"
  value       = google_dns_managed_zone.zone.id
}

output "zone_name" {
  description = "The name of the zone"
  value       = google_dns_managed_zone.zone.name
}

output "name_servers" {
  description = "The list of nameservers that will resolve records in this zone"
  value       = google_dns_managed_zone.zone.name_servers
}

output "domain" {
  description = "The DNS domain of the zone"
  value       = google_dns_managed_zone.zone.dns_name
}

output "visibility" {
  description = "The zone visibility (public or private)"
  value       = google_dns_managed_zone.zone.visibility
}

output "records" {
  description = "Map of DNS records created"
  value = {
    for record in google_dns_record_set.records :
    "${record.name}-${record.type}" => {
      name    = record.name
      type    = record.type
      ttl     = record.ttl
      records = record.rrdatas
    }
  }
}
