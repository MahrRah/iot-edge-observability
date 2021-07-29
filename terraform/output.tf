output "iot_hub_name" {
  value = module.iot_hub.iot_hub_name
}
output "edge_device_name" {
  value = module.iot_edge.edge_device_name
}
output "iot_edge_vm_public_ssh" {
  value = module.iot_edge.public_ssh
}

output "iot_edge_device_connction_string" {
  value     = module.iot_hub.device_connection_string
  sensitive = true
}
