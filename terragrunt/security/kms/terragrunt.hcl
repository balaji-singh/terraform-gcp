include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/security/kms"
}

inputs = {
  key_rings = {
    "security-keyring" = {
      name = "security-keyring"
      location = local.region
    }
  }

  crypto_keys = {
    "data-encryption-key" = {
      key_ring = "security-keyring"
      rotation_period = "7776000s"  # 90 days
      purpose = "ENCRYPT_DECRYPT"
      version_template = {
        algorithm = "GOOGLE_SYMMETRIC_ENCRYPTION"
        protection_level = "HSM"
      }
    }
  }
}
