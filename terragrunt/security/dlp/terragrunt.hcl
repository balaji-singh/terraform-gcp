include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/security/dlp"
}

inputs = {
  inspect_templates = {
    "sensitive-data-template" = {
      display_name = "Sensitive Data Template"
      description = "Template for detecting sensitive data"
      inspect_config = {
        info_types = [
          "CREDIT_CARD_NUMBER",
          "EMAIL_ADDRESS",
          "PHONE_NUMBER",
          "US_SOCIAL_SECURITY_NUMBER"
        ]
        min_likelihood = "LIKELY"
        limits = {
          max_findings_per_item = 100
          max_findings_per_request = 1000
        }
      }
    }
  }

  deidentify_templates = {
    "data-masking-template" = {
      display_name = "Data Masking Template"
      description = "Template for masking sensitive data"
      deidentify_config = {
        info_type_transformations = {
          transformations = [
            {
              primitive_transformation = "MASK_CONFIG"
              masking_char = "*"
              number_to_mask = 4
            }
          ]
        }
      }
    }
  }
}
