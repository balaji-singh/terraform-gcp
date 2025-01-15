output "policy" {
  description = "The created binary authorization policy"
  value = {
    id                           = google_binary_authorization_policy.policy.id
    default_admission_rule       = google_binary_authorization_policy.policy.default_admission_rule
    cluster_admission_rules      = google_binary_authorization_policy.policy.cluster_admission_rules
    admission_whitelist_patterns = google_binary_authorization_policy.policy.admission_whitelist_patterns
  }
}

output "attestors" {
  description = "Map of created attestors"
  value = {
    for k, v in google_binary_authorization_attestor.attestors : k => {
      id              = v.id
      name            = v.name
      description     = v.description
      note_reference  = v.attestation_authority_note[0].note_reference
    }
  }
}

output "attestor_iam_bindings" {
  description = "Map of IAM bindings for attestors"
  value = {
    for k, v in google_binary_authorization_attestor_iam_binding.attestor_bindings : k => {
      attestor = v.attestor
      role     = v.role
      members  = v.members
    }
  }
}
