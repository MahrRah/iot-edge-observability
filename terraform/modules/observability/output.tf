output "application_insights_instrumentation_key" {
  value = azurerm_application_insights.default.instrumentation_key
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.default.workspace_id
}

output "log_analytics_workspace_key" {
  value = azurerm_log_analytics_workspace.default.primary_shared_key
}
