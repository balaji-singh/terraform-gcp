locals {
  # Project configuration
  project_id      = get_env("TF_VAR_project_id")
  organization_id = get_env("TF_VAR_organization_id")
  billing_account = get_env("TF_VAR_billing_account")

  # Environment configuration
  environment = get_env("TF_VAR_environment", "dev")
  region      = get_env("TF_VAR_region", "us-central1")
  zones       = ["us-central1-a", "us-central1-b", "us-central1-c"]

  # Network configuration
  network_name = "vpc-${local.environment}"
  subnet_configs = {
    private = {
      name          = "private-${local.environment}"
      ip_cidr_range = "10.0.0.0/20"
      region        = local.region
    }
    public = {
      name          = "public-${local.environment}"
      ip_cidr_range = "10.0.16.0/20"
      region        = local.region
    }
  }

  # Security configuration
  security_config = {
    enable_os_login             = true
    enable_shielded_vm         = true
    enable_vpc_service_controls = true
    allowed_regions            = ["us-central1", "us-west1"]
  }

  # IAM configuration
  iam_config = {
    audit_log_retention_days = 365
    admin_group             = "gcp-admins@example.com"
    security_group          = "gcp-security@example.com"
  }

  # Monitoring configuration
  monitoring_config = {
    notification_channels = {
      email = ["alerts@example.com"]
      slack = ["#gcp-alerts"]
    }
    alert_policies = {
      cpu_utilization = 0.8
      memory_utilization = 0.8
    }
  }

  # Cost management
  budget_config = {
    amount = 1000
    alert_spent_percents = [0.5, 0.7, 0.9, 1.0]
    credit_types_treatment = "INCLUDE_ALL_CREDITS"
  }

  # Common labels
  labels = {
    environment = local.environment
    managed_by  = "terraform"
    team        = "platform"
  }

  # Service account configuration
  service_accounts = {
    terraform = {
      account_id   = "terraform-${local.environment}"
      display_name = "Terraform Service Account"
      description  = "Service account for Terraform automation"
    }
    monitoring = {
      account_id   = "monitoring-${local.environment}"
      display_name = "Monitoring Service Account"
      description  = "Service account for monitoring and logging"
    }
  }

  # Audit configuration
  audit_config = {
    services = [
      "allServices"
    ]
    audit_log_configs = {
      log_type         = "DATA_WRITE"
      exempted_members = []
    }
  }

  # Security scanner configuration
  security_scanner_config = {
    scan_schedule = "every 24 hours"
    target_platforms = ["COMPUTE"]
    export_to_security_center = true
  }
}
