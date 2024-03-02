locals {
  vnet_name = join("-", ["vnet", "test", "cac", var.env])
}

module "pme-private-endpoint" {
  source         = "app.terraform.io/flight-centre/pme-private-endpoint/azurerm"
  version        = "0.0.8"
  resource_group = azurerm_resource_group.rg.name
  env            = var.env
  private_endpoint = [
    {
      name = "airlink-cosmos"
      subnet = {
        name           = module.pme-virtualnetwork.subnet_name["cosmos"]
        vnet           = module.pme-virtualnetwork.vnet_name
        resource_group = module.pme-virtualnetwork.resource_group_name
      }
      target_service = {
        resouce_id        = module.pme-cosmos.cosmos_account_id
        subresource_names = ["sql"]
      }
      private_dns_zone = "privatelink.documents.azure.com"
    },
    {
      name = "airlink-appi"
      subnet = {
        name           = module.pme-virtualnetwork.subnet_name["applications"]
        vnet           = module.pme-virtualnetwork.vnet_name
        resource_group = module.pme-virtualnetwork.resource_group_name
      }
      target_service = {
        resouce_id        = module.pme-application-insights.ampls_id
        subresource_names = ["azuremonitor"]
      }
      private_dns_zone = "privatelink.monitor.azure.com"
    },
    {
      name = "airlinkfunc-keyvault"
      subnet = {
        name           = module.pme-virtualnetwork.subnet_name["keyvault"]
        vnet           = module.pme-virtualnetwork.vnet_name
        resource_group = module.pme-virtualnetwork.resource_group_name
      }
      target_service = {
        resouce_id        = module.pme-function-apps.key_vault_id["airlink"]
        subresource_names = ["vault"]
      }
      private_dns_zone = "privatelink.vaultcore.azure.net"
    },
    {
      name = "switchboard-keyvault"
      subnet = {
        name           = module.pme-virtualnetwork.subnet_name["keyvault"]
        vnet           = module.pme-virtualnetwork.vnet_name
        resource_group = module.pme-virtualnetwork.resource_group_name
      }
      target_service = {
        resouce_id        = module.pme-appservice.key_vault_id["switchboard"]
        subresource_names = ["vault"]
      }
      private_dns_zone = "privatelink.vaultcore.azure.net"
    },
    {
      name = "inferno-keyvault"
      subnet = {
        name           = module.pme-virtualnetwork.subnet_name["keyvault"]
        vnet           = module.pme-virtualnetwork.vnet_name
        resource_group = module.pme-virtualnetwork.resource_group_name
      }
      target_service = {
        resouce_id        = module.pme-appservice.key_vault_id["inferno"]
        subresource_names = ["vault"]
      }
      private_dns_zone = "privatelink.vaultcore.azure.net"
    },
    {
      name = "referencedata-keyvault"
      subnet = {
        name           = module.pme-virtualnetwork.subnet_name["keyvault"]
        vnet           = module.pme-virtualnetwork.vnet_name
        resource_group = module.pme-virtualnetwork.resource_group_name
      }
      target_service = {
        resouce_id        = module.pme-appservice.key_vault_id["referencedata"]
        subresource_names = ["vault"]
      }
      private_dns_zone = "privatelink.vaultcore.azure.net"
    },
    {
      name = "airlink-servicebus"
      subnet = {
        name           = module.pme-virtualnetwork.subnet_name["applications"]
        vnet           = module.pme-virtualnetwork.vnet_name
        resource_group = module.pme-virtualnetwork.resource_group_name
      }
      target_service = {
        resouce_id        = module.pme-servicebus.id
        subresource_names = ["namespace"]
      }
      private_dns_zone = "privatelink.servicebus.windows.net"
    },
    {
      name = "airlinkfunc-storageaccount"
      subnet = {
        name           = module.pme-virtualnetwork.subnet_name["storage"]
        vnet           = module.pme-virtualnetwork.vnet_name
        resource_group = module.pme-virtualnetwork.resource_group_name
      }
      target_service = {
        resouce_id        = module.pme-function-apps.storage_account_id["airlinkfunc"]
        subresource_names = ["blob"]
      }
      private_dns_zone = "privatelink.blob.core.windows.net"
    }
  ]
  depends_on = [module.pme-virtualnetwork.vnet_name]
}
