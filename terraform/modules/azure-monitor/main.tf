resource "azurerm_application_insights" "default" {
  name                = "${var.resource_prefix}-ai"
  resource_group_name = var.resource_group_name
  location            = var.location
  application_type    = "other"
}


resource "azurerm_log_analytics_workspace" "default" {
  name                = "${var.resource_prefix}-ws"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_in_days
}
