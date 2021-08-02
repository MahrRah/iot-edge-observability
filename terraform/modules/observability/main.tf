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

# Storage account
resource "azurerm_storage_account" "example" {
  name                     = "${var.resource_prefix}storageaccount"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}
# App service plan and Function app

resource "azurerm_app_service_plan" "example" {
  name                = "${var.resource_prefix}-service-plan"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "example" {
  name                       = "${var.resource_prefix}-azure-functions"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  app_service_plan_id        = azurerm_app_service_plan.example.id
  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
}