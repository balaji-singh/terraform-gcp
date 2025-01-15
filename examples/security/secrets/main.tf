provider "google" {
  project = var.project_id
  region  = var.region
}

module "secret_manager" {
  source = "../../../modules/security/secrets"

  project_id = var.project_id
  
  labels = {
    environment = "production"
    team        = "security"
  }

  secrets = {
    "app-credentials" = {
      labels = {
        app = "myapp"
      }
      replication = {
        automatic = {
          customer_managed_encryption = {
            kms_key_name = "projects/${var.project_id}/locations/global/keyRings/my-keyring/cryptoKeys/my-key"
          }
        }
      }
      rotation = {
        rotation_period = "7776000s"  # 90 days
      }
      versions = [
        {
          version     = "1"
          secret_data = "initial-secret-value"
          enabled     = true
        }
      ]
    },
    "api-keys" = {
      replication = {
        user_managed = {
          replicas = [
            {
              location = "us-central1"
              customer_managed_encryption = {
                kms_key_name = "projects/${var.project_id}/locations/us-central1/keyRings/my-keyring/cryptoKeys/my-key"
              }
            },
            {
              location = "us-west1"
              customer_managed_encryption = {
                kms_key_name = "projects/${var.project_id}/locations/us-west1/keyRings/my-keyring/cryptoKeys/my-key"
              }
            }
          ]
        }
      }
      topics = [
        {
          name = "projects/${var.project_id}/topics/secret-rotation"
        }
      ]
      versions = [
        {
          version     = "1"
          secret_data = "api-key-value"
          enabled     = true
        }
      ]
    }
  }

  iam_bindings = {
    "app-credentials-accessor" = {
      secret_id = "app-credentials"
      role      = "roles/secretmanager.secretAccessor"
      members   = ["serviceAccount:app-sa@${var.project_id}.iam.gserviceaccount.com"]
    },
    "api-keys-admin" = {
      secret_id = "api-keys"
      role      = "roles/secretmanager.admin"
      members   = ["group:security-admins@example.com"]
      condition = {
        title       = "temporary_access"
        description = "Temporary admin access"
        expression  = "request.time < timestamp('2024-12-31T23:59:59Z')"
      }
    }
  }
}
