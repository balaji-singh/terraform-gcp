include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/security/pod_security"
}

dependency "container" {
  config_path = "../container"
}

inputs = {
  pod_security_policies = {
    "restricted" = {
      name = "restricted"
      spec = {
        privileged = false
        allow_privilege_escalation = false
        allowed_capabilities = []
        volumes = [
          "configMap",
          "emptyDir",
          "projected",
          "secret",
          "downwardAPI",
          "persistentVolumeClaim"
        ]
        run_as_user = {
          rule = "MustRunAsNonRoot"
        }
        se_linux = {
          rule = "RunAsAny"
        }
        supplemental_groups = {
          rule = "MustRunAs"
          ranges = [
            {
              min = 1
              max = 65535
            }
          ]
        }
        fs_group = {
          rule = "MustRunAs"
          ranges = [
            {
              min = 1
              max = 65535
            }
          ]
        }
        read_only_root_filesystem = true
      }
    }
  }

  namespace_policies = {
    "prod-security" = {
      name = "prod-security"
      namespace = "prod"
      policy = "restricted"
      enforcement = "enforcing"
    }
    "dev-security" = {
      name = "dev-security"
      namespace = "dev"
      policy = "restricted"
      enforcement = "warning"
    }
  }

  security_contexts = {
    "secure-context" = {
      run_as_non_root = true
      run_as_user = 1000
      run_as_group = 3000
      fs_group = 2000
      sysctls = [
        {
          name = "net.ipv4.tcp_syncookies"
          value = "0"
        }
      ]
      capabilities = {
        drop = ["ALL"]
      }
      seccomp_profile = {
        type = "RuntimeDefault"
      }
    }
  }

  admission_control = {
    "pod-security" = {
      enabled = true
      configuration = {
        defaults = {
          enforce = "restricted"
          enforce-version = "latest"
          audit = "restricted"
          audit-version = "latest"
          warn = "restricted"
          warn-version = "latest"
        }
        exemptions = {
          usernames = []
          runtime_classes = []
          namespaces = ["kube-system"]
        }
      }
    }
  }

  monitoring_config = {
    metrics = {
      "policy_violations" = {
        type = "custom.googleapis.com/security/pod_violations"
        description = "Pod security policy violations"
      }
    }
    alerts = {
      "violation_alert" = {
        condition = "pod_violations > 0"
        notification_channels = ["email", "slack"]
      }
    }
  }

  audit_config = {
    "pod-security-audit" = {
      log_type = "k8s-audit"
      filter = "objectRef.resource=pods"
      destination = "logging.googleapis.com"
    }
  }

  compliance_config = {
    "pod-compliance" = {
      standards = ["CIS", "SOC2"]
      checks = [
        "privileged_containers",
        "host_network_ports",
        "volume_types",
        "root_containers"
      ]
      reporting = {
        enabled = true
        frequency = "daily"
        recipients = ["security@example.com"]
      }
    }
  }
}
