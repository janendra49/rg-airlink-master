
variable "cosmos_account_failover_location" {
  type    = string
  default = null
}

module "pme-cosmos" {
  source                           = "app.terraform.io/flight-centre/pme-cosmos/azurerm"
  version                          = "1.6.4"
  rg_name                          = azurerm_resource_group.rg.name
  env                              = var.env
  cosmos_account_offer_type        = "Standard"
  cosmos_account_kind              = "GlobalDocumentDB"
  cosmos_account_location          = azurerm_resource_group.rg.location
  cosmos_account_failover_location = var.cosmos_account_failover_location
  public_network_enabled           = false
  use_free_tier                    = false
  azservice_networkbypass          = false
  cosmos_account = {
    name = "cosmos-airlink",
    cosmos_db = [
      {
        name       = "airlink-entities",
        containers = []
      }
    ]
  }
}
