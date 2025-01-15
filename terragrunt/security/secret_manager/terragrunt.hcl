include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/security/secret_manager"
}

dependency "kms" {
  config_path = "../kms"
}

inputs = {
  secrets = {
    "api-keys" = {
      secret_id = "api-keys"
      replication = {
        automatic = true
      }
      rotation = {
        next_rotation_time = timeadd(timestamp(), "720h")
        rotation_period = "720h"
      }
      encryption = {
        kms_key_name = dependency.kms.outputs.crypto_keys["data-encryption-key"].id
      }
    }
    "database-credentials" = {
      secret_id = "database-credentials"
      replication = {
        user_managed = {
          replicas = [
            {
              location = "us-central1"
              customer_managed_encryption = {
                kms_key_name = dependency.kms.outputs.crypto_keys["data-encryption-key"].id
              }
            },
            {
              location = "us-east1"
              customer_managed_encryption = {
                kms_key_name = dependency.kms.outputs.crypto_keys["data-encryption-key"].id
              }
            }
          ]
        }
      }
    }
  }

  secret_versions = {
    "api-keys" = {
      secret = "api-keys"
      data = file("${get_terragrunt_dir()}/secrets/api-keys.yaml")
    }
    "database-credentials" = {
      secret = "database-credentials"
      data = file("${get_terragrunt_dir()}/secrets/db-creds.yaml")
    }
  }

  iam_bindings = {
    "secret-accessor" = {
      role = "roles/secretmanager.secretAccessor"
      members = [
        "serviceAccount:${local.project_id}-sa@${local.project_id}.iam.gserviceaccount.com"
      ]
    }
    "secret-admin" = {
      role = "roles/secretmanager.admin"
      members = [
        "group:security-admins@example.com"
      ]
    }
  }

  monitoring_config = {
    alerts = {
      "secret-access" = {
        condition = "resource.type=secret AND protoPayload.methodName=AccessSecretVersion"
        notification_channels = ["email", "slack"]
      }
      "secret-rotation" = {
        condition = "resource.type=secret AND rotation.next_rotation_time < timestamp(NOW - 24h)"
        notification_channels = ["email"]
      }
    }
  }

  audit_config = {
    "secret-audit" = {
      log_type = "secret-audit"
      filter = "resource.type=secret"
      destination = "logging.googleapis.com"
    }
  }
}
