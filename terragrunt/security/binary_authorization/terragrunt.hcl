include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/security/binary_authorization"
}

dependency "container" {
  config_path = "../container"
}

inputs = {
  policy_config = {
    global_policy_evaluation_mode = "ENABLE"
    default_admission_rule = {
      evaluation_mode = "REQUIRE_ATTESTATION"
      enforcement_mode = "ENFORCED_BLOCK_AND_AUDIT_LOG"
      attestation_patterns = {
        google_binary_authorization_attestor = {
          name = "security-attestor"
          note_reference = "projects/${local.project_id}/notes/security-note"
        }
      }
    }
  }
}
