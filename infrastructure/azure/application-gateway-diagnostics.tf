locals {
  agw_diagnostics = sort([
    "ApplicationGatewayAccessLog",
    "ApplicationGatewayFirewallLog",
    "ApplicationGatewayPerformanceLog",
  ])
}

resource "azurerm_monitor_diagnostic_setting" "agw" {
  name                       = "diagnostics-agw"
  target_resource_id         = azurerm_application_gateway.agw.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.diagnostics.id

  dynamic "log" {
    for_each = local.agw_diagnostics
    content {
      category = log.value
      enabled  = true

      retention_policy {
        enabled = false
        days    = 0
      }
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }
}