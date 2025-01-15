include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/security/ssl_policy"
}

inputs = {
  ssl_policies = {
    "strict-ssl" = {
      name = "strict-ssl-policy"
      profile = "RESTRICTED"
      min_tls_version = "TLS_1_2"
      custom_features = ["TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384", "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"]
    }
    "modern-ssl" = {
      name = "modern-ssl-policy"
      profile = "MODERN"
      min_tls_version = "TLS_1_2"
    }
  }

  certificate_config = {
    managed_certificates = {
      "primary-cert" = {
        domains = ["example.com", "*.example.com"]
        dns_authorizations = true
      }
    }
    self_managed_certificates = {
      "internal-cert" = {
        certificate = file("${get_terragrunt_dir()}/certs/internal.crt")
        private_key = file("${get_terragrunt_dir()}/certs/internal.key")
      }
    }
  }

  security_headers = {
    "secure-headers" = {
      strict_transport_security = "max-age=31536000; includeSubDomains; preload"
      content_security_policy = "default-src 'self'; script-src 'self'"
      x_frame_options = "DENY"
      x_content_type_options = "nosniff"
      x_xss_protection = "1; mode=block"
    }
  }

  monitoring_config = {
    alerts = {
      "cert-expiry" = {
        condition = "certificate.expiry < 30d"
        notification_channels = ["email", "slack"]
      }
      "ssl-version" = {
        condition = "ssl.version < TLS_1_2"
        notification_channels = ["email"]
      }
    }
  }
}
