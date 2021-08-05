output "application_insights_instrumentation_key" {
  value = azurerm_application_insights.default.instrumentation_key
}

output "function_app_key" {
  value = data.azurerm_function_app_host_keys.example.default_function_key
  }

output "function_app_host" {
  value = "https://${azurerm_function_app.example.default_hostname}"
}


output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.default.workspace_id
}

output "log_analytics_workspace_key" {
  value = azurerm_log_analytics_workspace.default.primary_shared_key
}

output "storage_account_connection_string" {
  value = azurerm_storage_account.example.primary_connection_string
}

output "storage_queue_name" {
  value = azurerm_storage_queue.example.name
}

output "storage_container_name" {
  value = azurerm_storage_container.example.name
}
