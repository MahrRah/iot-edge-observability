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
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "example" {
  name                  = "${var.resource_prefix}-device-logs"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

resource "azurerm_storage_queue" "example" {
  name                 = "test-queue"
  storage_account_name = azurerm_storage_account.example.name
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

data "azurerm_function_app_host_keys" "example" {
  name                = azurerm_function_app.example.name
  resource_group_name =  var.resource_group_name
}

resource "azurerm_eventgrid_event_subscription" "example" {
  name  = "defaultEventSubscription"
  scope = var.resource_group_id
  event_delivery_schema = "EventGridSchema"
  included_event_types  = ["Microsoft.Storage.BlobCreated","Microsoft.Storage.BlobDelete"]


  storage_queue_endpoint {
    storage_account_id = azurerm_storage_account.example.id
    queue_name         = azurerm_storage_queue.example.name
  }
}