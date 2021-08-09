output "iot_hub_name" {
  value = module.iot_hub.iot_hub_name
}
output "edge_device_name" {
  value = module.iot_edge.edge_device_name
}
output "iot_edge_vm_public_ssh" {
  value = module.iot_edge.public_ssh
}

output "DEVICE_CONNECTION_STRING" {
  value     = module.iot_hub.device_connection_string
  sensitive = true
}

output "STORAGE_CONNECTION_STRING" {
  value     = module.observability.storage_account_connection_string
  sensitive = true
}

output "IOTHUB_CONNECTION_STRING" {
  value     = module.iot_hub.iothub_connection_string
  sensitive = true
}

output "LOG_ANALYTICS_WORKSPACE_ID" {
  value = module.observability.log_analytics_workspace_id
}

output "LOG_ANALYTICS_WORKSPACE_KEY" {
  value     = module.observability.log_analytics_workspace_key
  sensitive = true

}
output "IOT_HUB_RESOURCE_ID" {
  value = module.iot_hub.iot_hub_resource_id
}


output "FUNCTION_HOST" {
  value     = module.observability.function_app_host
}

output "FUNCTION_KEY" {
  value     = module.observability.function_app_key
  sensitive = true
}

output "QUEUE_NAME" {
  value     = module.observability.storage_queue_name
}

output "CONTAINER_NAME" {
  value     = module.observability.storage_container_name
}

output "CONTAINER_REGISTRY_SERVER" {
  value = azurerm_container_registry.acr.login_server
}

output "CONTAINER_REGISTRY_USERNAME" {
  value =  azurerm_container_registry.acr.admin_username
}

output "CONTAINER_REGISTRY_PASSWORD" {
  value     =  azurerm_container_registry.acr.admin_password
  sensitive = true
}