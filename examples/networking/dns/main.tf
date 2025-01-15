provider "google" {
  project = var.project_id
  region  = var.region
}

module "cloud_dns" {
  source = "../../../modules/networking/dns"

  project_id = var.project_id
  zone_name  = "example-zone"
  dns_name   = "example.com."
  
  description = "Example DNS zone"
  
  # Private DNS configuration
  private_zone = true
  networks = [
    "projects/${var.project_id}/global/networks/my-vpc"
  ]
  
  # DNSSEC configuration
  enable_dnssec = true
  dnssec_key_algorithm = "rsasha256"
  dnssec_key_length   = 2048
  
  # DNS records
  records = [
    {
      name    = "www.example.com."
      type    = "A"
      ttl     = 300
      records = ["203.0.113.10"]
    },
    {
      name    = "api.example.com."
      type    = "A"
      ttl     = 300
      records = ["203.0.113.11"]
    },
    {
      name    = "example.com."
      type    = "MX"
      ttl     = 3600
      records = [
        "1 aspmx.l.google.com.",
        "5 alt1.aspmx.l.google.com.",
        "5 alt2.aspmx.l.google.com."
      ]
    }
  ]
  
  enable_inbound_forwarding = true
  
  labels = {
    environment = "production"
    team        = "platform"
  }
}
