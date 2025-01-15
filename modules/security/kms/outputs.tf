output "key_ring" {
  description = "The created KMS key ring"
  value = {
    id       = google_kms_key_ring.key_ring.id
    name     = google_kms_key_ring.key_ring.name
    location = google_kms_key_ring.key_ring.location
  }
}

output "crypto_keys" {
  description = "Map of created crypto keys"
  value = {
    for k, v in google_kms_crypto_key.crypto_keys : k => {
      id              = v.id
      name            = v.name
      rotation_period = v.rotation_period
      purpose         = v.purpose
      version_template = v.version_template
    }
  }
}

output "import_jobs" {
  description = "Map of created import jobs"
  value = {
    for k, v in google_kms_key_ring_import_job.import_jobs : k => {
      id               = v.id
      name             = v.name
      import_method    = v.import_method
      protection_level = v.protection_level
      state           = v.state
    }
  }
}
