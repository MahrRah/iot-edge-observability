terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.45.1"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "random_id" "prefix" {
  byte_length = 4
}

locals {
  resource_prefix  = lower(random_id.prefix.hex)
  edge_device_name = "${local.resource_prefix}-edge-device"
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.resource_prefix}-rg-sense-development"
  location = var.resource_group_location
}
module "observability" {
  source              = "./modules/observability"
  resource_prefix     = local.resource_prefix
  resource_group_name = azurerm_resource_group.rg.name
  resource_group_id = azurerm_resource_group.rg.id
  location            = var.resource_group_location
  retention_in_days   = var.log_analytics_retention_period
}
module "iot_hub" {
  source              = "./modules/iot-hub"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.resource_group_location
  resource_prefix     = local.resource_prefix
  edge_device_name    = local.edge_device_name
}

module "iot_edge" {
  source                   = "./modules/iot-edge"
  resource_prefix          = local.resource_prefix
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.resource_group_location
  vm_user_name             = var.edge_vm_user_name
  vm_sku                   = var.edge_vm_sku
  edge_vm_name             = local.edge_device_name
  device_connection_string = module.iot_hub.device_connection_string
}

