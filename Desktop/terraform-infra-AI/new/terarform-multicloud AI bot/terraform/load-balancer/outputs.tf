output "lb_id" {
  description = "Load balancer ID"
  value       = azurerm_lb.main.id
}

output "backend_pool_id" {
  description = "Backend pool ID"
  value       = azurerm_lb_backend_address_pool.app.id
}
