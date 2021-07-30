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

output "IOTHUB_CONNECTION_STRING" {
  value     = module.iot_hub.iothub_connection_string
  sensitive = true
}

output "LOG_ANALYTICS_WORKSPACE_ID" {
  value = module.azure-monitor.log_analytics_workspace_id
}

output "LOG_ANALYTICS_WORKSPACE_KEY" {
  value     = module.azure-monitor.log_analytics_workspace_key
  sensitive = true

}
output "IOT_HUB_RESOURCE_ID" {
  value = module.iot_hub.iot_hub_resource_id
}