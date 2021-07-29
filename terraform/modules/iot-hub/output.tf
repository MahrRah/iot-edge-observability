output "iot_hub_name" {
  value = azurerm_iothub.example.name
}
output "device_connection_string" {
  value     = shell_script.register_iot_edge_device.output["connectionString"]
  sensitive = true
}
