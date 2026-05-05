resource "azurerm_log_analytics_workspace" "main" {
  name                = "LAW-AZURE-DEV-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_monitor_metric_alert" "cpu_high" {
  name                = "ALERT-AZURE-CPU-HIGH-DEV-01"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_id]
  description         = "CPU utilization exceeds 80% in dev"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = var.action_group_id
  }
}

resource "azurerm_dashboard" "main" {
  name                = "DASH-AZURE-DEV-01"
  resource_group_name = var.resource_group_name
  location            = var.location
  dashboard_properties = jsonencode({
    lenses = {}
  })

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
