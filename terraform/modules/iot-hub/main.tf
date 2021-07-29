
terraform {
  required_providers {
    shell = {
      source  = "scottwinkler/shell"
      version = "1.7.7"
    }
  }
}
provider "shell" {}

locals {
  iot_edge_id = "${var.resource_prefix}-edge-device"
}

data "azurerm_subscription" "current" {
}

resource "azurerm_iothub" "example" {
  name                          = "${var.resource_prefix}-iot-hub"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  public_network_access_enabled = true

  sku {
    name     = "S1"
    capacity = "1"
  }

  route {
    name           = "defaultroute"
    source         = "DeviceMessages"
    condition      = "true"
    endpoint_names = ["events"]
    enabled        = true
  }

  tags = {
    purpose = "testing"
  }
}


resource "azurerm_iothub_shared_access_policy" "example" {
  name                = "iot_hub_sas"
  resource_group_name = var.resource_group_name
  iothub_name         = azurerm_iothub.example.name
  registry_read       = true # allow reading from device registry
  registry_write      = true # allow writing to device registry
  service_connect     = true # allows c2d communication and access to service endpoints
  device_connect      = true # allows sending and receiving on the device-side endpoints
}

resource "shell_script" "register_iot_edge_device" {
  lifecycle_commands {
    create = "$SCRIPT create"
    read   = "$SCRIPT read"
    delete = "$SCRIPT delete"
  }


  environment = {
    IOT_HUB_NAME         = azurerm_iothub.example.name
    IOT_EDGE_DEVICE_NAME = local.iot_edge_id
    SCRIPT               = "../scripts/register_iot_edge_device.sh"
  }

  depends_on = [
    azurerm_iothub_shared_access_policy.example
  ]
}
