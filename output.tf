output "vpc_link" {
  value       = google_compute_network.vpc_network.self_link
  description = "The link of vpc."
}
output "subnet_link" {
  value       = google_compute_subnetwork.subnet.self_link
  description = "The link of subnet."
}