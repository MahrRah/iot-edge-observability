output "iot_hub_name" {
  value = azurerm_iothub.example.name
}
output "device_connection_string" {
  value     = shell_script.register_iot_edge_device.output["connectionString"]
  sensitive = true
}
output "iot_hub_resource_id" {
  value = "subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_iothub.example.resource_group_name}/providers/Microsoft.Devices/IotHubs/${azurerm_iothub.example.name}"
}
