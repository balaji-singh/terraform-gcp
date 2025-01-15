output "security_policy" {
  description = "The created security policy"
  value = {
    id          = google_compute_security_policy.policy.id
    name        = google_compute_security_policy.policy.name
    self_link   = google_compute_security_policy.policy.self_link
    fingerprint = google_compute_security_policy.policy.fingerprint
  }
}

output "edge_security_policy" {
  description = "The created edge security policy"
  value = var.create_edge_policy ? {
    id          = google_compute_security_policy.edge_policy[0].id
    name        = google_compute_security_policy.edge_policy[0].name
    self_link   = google_compute_security_policy.edge_policy[0].self_link
    fingerprint = google_compute_security_policy.edge_policy[0].fingerprint
  } : null
}

output "rules" {
  description = "List of rules in the security policy"
  value = [
    for rule in google_compute_security_policy.policy.rule : {
      action      = rule.action
      priority    = rule.priority
      description = rule.description
    }
  ]
}
