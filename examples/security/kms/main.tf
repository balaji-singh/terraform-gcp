provider "google" {
  project = var.project_id
  region  = var.region
}

module "kms" {
  source = "../../../modules/security/kms"

  project_id    = var.project_id
  location      = "global"
  key_ring_name = "example-keyring"

  # Crypto Keys
  crypto_keys = {
    "app-key" = {
      rotation_period = "7776000s"  # 90 days
      labels = {
        environment = "production"
        app         = "myapp"
      }
      purpose = "ENCRYPT_DECRYPT"
      version_template = {
        algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
        protection_level = "SOFTWARE"
      }
    }
    "signing-key" = {
      rotation_period = "15552000s"  # 180 days
      labels = {
        environment = "production"
        purpose     = "signing"
      }
      purpose = "ASYMMETRIC_SIGN"
      version_template = {
        algorithm        = "RSA_SIGN_PSS_2048_SHA256"
        protection_level = "HSM"
      }
      skip_initial_version_creation = false
    }
  }

  # Crypto Key IAM Bindings
  crypto_key_iam_bindings = {
    "app-key-binding" = {
      crypto_key_name = "app-key"
      role           = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
      members        = ["serviceAccount:app-sa@${var.project_id}.iam.gserviceaccount.com"]
    }
    "signing-key-binding" = {
      crypto_key_name = "signing-key"
      role           = "roles/cloudkms.signer"
      members        = ["serviceAccount:signing-sa@${var.project_id}.iam.gserviceaccount.com"]
    }
  }

  # Key Ring IAM Bindings
  key_ring_iam_bindings = {
    "keyring-admin" = {
      role    = "roles/cloudkms.admin"
      members = ["group:kms-admins@example.com"]
    }
    "keyring-viewer" = {
      role    = "roles/cloudkms.viewer"
      members = ["group:security-team@example.com"]
    }
  }

  # Import Jobs
  import_jobs = {
    "import-job-1" = {
      import_method    = "RSA_OAEP_3072_SHA256_AES_256"
      protection_level = "SOFTWARE"
      expires_at      = timeadd(timestamp(), "24h")
    }
  }
}
