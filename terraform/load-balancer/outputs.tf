output "lb_ip" {
  description = "Load balancer IP"
  value       = google_compute_global_forwarding_rule.https.ip_address
}
