include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/security/container_analysis"
}

dependency "container" {
  config_path = "../container"
}

inputs = {
  analysis_config = {
    note_config = {
      "vulnerability-note" = {
        short_description = "Container Vulnerability Analysis"
        long_description = "Detailed analysis of container vulnerabilities"
        related_url = {
          url = "https://cloud.google.com/container-analysis/docs"
          label = "Documentation"
        }
        vulnerability = {
          severity = "CRITICAL"
          details = {
            type = "PACKAGE"
            severity = "CRITICAL"
            package = "all"
          }
        }
      }
      "deployment-note" = {
        short_description = "Container Deployment Analysis"
        long_description = "Analysis of container deployments"
        related_url = {
          url = "https://cloud.google.com/binary-authorization/docs"
          label = "Documentation"
        }
        deployment = {
          deployment_type = "CONTINUOUS"
          platform = "KUBERNETES"
        }
      }
    }
    occurrence_config = {
      "vulnerability-scan" = {
        note_name = "vulnerability-note"
        vulnerability_details = {
          type = "VULNERABILITY"
          severity = "CRITICAL"
          package_issue = {
            affected_package = "all"
            affected_version = {
              kind = "MINIMUM"
            }
            fixed_version = {
              kind = "MAXIMUM"
            }
          }
        }
      }
    }
  }

  scan_config = {
    scan_on_push = true
    scan_on_pull = true
    vulnerability_scanning = {
      enabled = true
      scanning_mode = "CONTINUOUS_SCAN"
    }
  }

  policy_config = {
    admission_whitelist_patterns = [
      "gcr.io/${local.project_id}/*"
    ]
    default_admission_rule = {
      evaluation_mode = "ALWAYS_ALLOW"
      enforcement_mode = "ENFORCED_BLOCK_AND_AUDIT_LOG"
    }
    cluster_admission_rules = {
      "prod-cluster" = {
        evaluation_mode = "REQUIRE_ATTESTATION"
        enforcement_mode = "ENFORCED_BLOCK_AND_AUDIT_LOG"
        require_attestations = [
          "projects/${local.project_id}/attestors/security-attestor",
          "projects/${local.project_id}/attestors/quality-attestor"
        ]
      }
    }
  }

  attestation_config = {
    attestors = {
      "security-attestor" = {
        name = "security-attestor"
        description = "Attestor for security requirements"
        note_reference = "projects/${local.project_id}/notes/security-note"
        pgp_public_key = {
          id = "security-key-id"
          ascii_armored = file("${get_terragrunt_dir()}/keys/security.pub")
        }
      }
      "quality-attestor" = {
        name = "quality-attestor"
        description = "Attestor for quality requirements"
        note_reference = "projects/${local.project_id}/notes/quality-note"
        pgp_public_key = {
          id = "quality-key-id"
          ascii_armored = file("${get_terragrunt_dir()}/keys/quality.pub")
        }
      }
    }
  }

  notification_config = {
    vulnerability_alerts = {
      pubsub_topic = "projects/${local.project_id}/topics/vulnerability-alerts"
      filter = "severity = CRITICAL OR severity = HIGH"
    }
    deployment_alerts = {
      pubsub_topic = "projects/${local.project_id}/topics/deployment-alerts"
      filter = "type = DEPLOYMENT"
    }
  }
}
