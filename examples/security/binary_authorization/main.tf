provider "google" {
  project = var.project_id
  region  = var.region
}

module "binary_authorization" {
  source = "../../../modules/security/binary_authorization"

  project_id = var.project_id
  description = "Binary Authorization policy for container deployment"

  global_policy_evaluation_mode = "ENABLE"

  # Default admission rule
  default_admission_rule = {
    evaluation_mode         = "REQUIRE_ATTESTATION"
    enforcement_mode        = "ENFORCED_BLOCK_AND_AUDIT_LOG"
    require_attestations_by = []  # Will be populated with attestor names
  }

  # Cluster-specific admission rules
  cluster_admission_rules = {
    "us-central1-a.prod-cluster" = {
      evaluation_mode         = "REQUIRE_ATTESTATION"
      enforcement_mode        = "ENFORCED_BLOCK_AND_AUDIT_LOG"
      require_attestations_by = ["projects/${var.project_id}/attestors/security-attestor"]
    },
    "us-west1-a.dev-cluster" = {
      evaluation_mode         = "ALWAYS_ALLOW"
      enforcement_mode        = "ENFORCED_BLOCK_AND_AUDIT_LOG"
      require_attestations_by = []
    }
  }

  # Whitelist patterns
  admission_whitelist_patterns = [
    "gcr.io/google_containers/*",
    "k8s.gcr.io/*",
    "gke.gcr.io/*"
  ]

  # Attestors
  attestors = {
    "security-attestor" = {
      description    = "Security attestor for production deployments"
      note_reference = "projects/${var.project_id}/notes/security-note"
      public_keys = [
        {
          public_key_pem = file("${path.module}/keys/attestor.pub")
          signature_algorithm = "RSA_PSS_SHA256"
        }
      ]
      ascii_armored_pgp_public_keys = []
      key_id  = "security-key"
      comment = "Security attestation key"
    },
    "quality-attestor" = {
      description    = "Quality assurance attestor"
      note_reference = "projects/${var.project_id}/notes/quality-note"
      public_keys = [
        {
          public_key_pem = file("${path.module}/keys/quality.pub")
          signature_algorithm = "RSA_PSS_SHA256"
        }
      ]
      ascii_armored_pgp_public_keys = []
      key_id  = "quality-key"
      comment = "Quality assurance key"
    }
  }

  # Attestor IAM bindings
  attestor_iam_bindings = {
    "security-attestor-admin" = {
      attestor_name = "security-attestor"
      role          = "roles/binaryauthorization.attestorsAdmin"
      members       = ["group:security-admins@example.com"]
    },
    "quality-attestor-viewer" = {
      attestor_name = "quality-attestor"
      role          = "roles/binaryauthorization.attestorsViewer"
      members       = ["group:quality-team@example.com"]
    }
  }
}
