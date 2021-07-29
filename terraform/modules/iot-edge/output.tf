output "public_ssh" {
  value = "ssh -i ../../.ssh/id_rsa ${local.vm_user_name}@${azurerm_public_ip.iot_edge.fqdn}"
}

output "edge_device_name" {
  value = azurerm_linux_virtual_machine.iot_edge.name
}
