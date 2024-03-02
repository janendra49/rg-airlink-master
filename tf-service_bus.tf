variable "servicebus_sku" {
  type = string
}

module "pme-servicebus" {
  source                           = "app.terraform.io/flight-centre/pme-servicebus/azurerm"
  version                          = "0.0.10"
  env                              = var.env
  resource_group                   = azurerm_resource_group.rg.name
  location                         = azurerm_resource_group.rg.location
  servicebus_name                  = "airlink-invoicing"
  servicebus_sku                   = var.servicebus_sku
  servicebus_capacity              = 1
  servicebus_public_network_access = false
  topic = [{
    name = "order-airlink-invoicing"
    subscriptions = [{
      name               = "prime-airlink-invoicing"
      max_delivery_count = 10
    }]
  }]
  queue = []
  shared_access_policy = [{
    name   = "AirlinkSwitchboardAccessKey"
    listen = true
    send   = true
    manage = false
  }]
  log_analytics_id = module.pme-application-insights.law_id
}
