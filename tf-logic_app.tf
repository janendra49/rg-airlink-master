locals {
  function_app_id = module.pme-function-apps.function_app_id
}

module "pme-logicapp" {
  source         = "app.terraform.io/flight-centre/pme-logicapp/azurerm"
  version        = "0.0.9"
  project        = "orderretrieve-invoicing-app"
  resource_group = azurerm_resource_group.rg.name
  location       = azurerm_resource_group.rg.location
  env            = var.env
  logicapp_action = jsondecode(
    replace(
      file("logicapp_config/logicapp_action.json"),
      "<<function_app_id>>", module.pme-function-apps.function_app_id["airlink"]
    )
  )
  logicapp_trigger = jsondecode(
    replace(
      replace(
        file("logicapp_config/logicapp_trigger.json"),
        "<<subscription_name>>", module.pme-servicebus.topic_subscription_name["prime-airlink-invoicing"]
      ),
      "<<topic_name>>", module.pme-servicebus.topic_name["order-airlink-invoicing"]
    )
  )
  log_analytics = { name = module.pme-application-insights.law_name, resource_group = module.pme-application-insights.resource_group_name }

  workflow_parameters = {
    "$connections" = {
      type         = "Object"
      defaultValue = {}
    }
  }

  parameters = {
    "$connections" = {
      "servicebus" = {
        connectionId   = azurerm_api_connection.servicebus.id
        connectionName = azurerm_api_connection.servicebus.name
        id             = data.azurerm_managed_api.servicebus.id
      }
    }
  }
}

data "azurerm_managed_api" "servicebus" {
  name       = "servicebus"
  location   = azurerm_resource_group.rg.location
  depends_on = [module.pme-servicebus.name]
}

resource "azurerm_api_connection" "servicebus" {
  name                = "apiconn-${module.pme-servicebus.name}"
  resource_group_name = azurerm_resource_group.rg.name
  managed_api_id      = data.azurerm_managed_api.servicebus.id

  parameter_values = {
    connectionString = module.pme-servicebus.primary_connection_string
  }

  lifecycle {
    # NOTE: since the connectionString is a secure value it's not returned from the API
    ignore_changes = [parameter_values]
  }
}
