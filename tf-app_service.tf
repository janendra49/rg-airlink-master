variable "as_asp_sku" {
  type = string
}

locals {
  as_supp_name = "airlinkweb"
  as_ip_restriction = [
    {
      action      = "Allow"
      name        = "APIM CanadaCentral"
      priority    = 100
      service_tag = "ApiManagement.CanadaCentral"
    },
    {
      action                    = "Allow"
      name                      = "snet-function"
      priority                  = 110
      virtual_network_subnet_id = module.pme-virtualnetwork.subnet_id["function"]
    },
    {
      action      = "Allow"
      name        = "AzureDevOps"
      priority    = 120
      service_tag = "AzureDevOps"
    }
  ]
}

module "pme-appservice" {
  source         = "app.terraform.io/flight-centre/pme-appservice/azurerm"
  version        = "0.0.21"
  resource_group = azurerm_resource_group.rg.name
  location       = azurerm_resource_group.rg.location
  env            = var.env
  app_service_plan = [{
    name = local.as_supp_name
    sku  = var.as_asp_sku
  }]
  app_service = [
    {
      name                    = "switchboard"
      app_service_plan        = local.as_supp_name
      ftps_state              = "Disabled"
      key_vault_public_access = false
      always_on               = true
      app_settings = {
        "ASPNETCORE_ENVIRONMENT"                           = "Development"
        "Authentication:ApiKey"                            = "@Microsoft.KeyVault(SecretUri=https://kv-switchboard${var.env}cac.vault.azure.net/secrets/AuthenticationApiKey/)"
        "CosmosDatabase:ConnectionString"                  = "@Microsoft.KeyVault(SecretUri=https://kv-switchboard${var.env}cac.vault.azure.net/secrets/CosmosDatabaseConnectionString/)"
        "CosmosDatabase:ContainerDefaultTimeToLiveDays"    = 90
        "CosmosDatabase:DatabaseName"                      = "cosmos-airlink-entities"
        "FeatureFlags:EntityGenerationForTPConnectsEvents" = true
        "ServiceBusMessageHandler:ConnectionString"        = "@Microsoft.KeyVault(SecretUri=https://kv-switchboard${var.env}cac.vault.azure.net/secrets/ServiceBusMessageHandlerConnectionString/)"
        "ServiceBusMessageHandler:TopicName"               = "sbt-order-airlink-invoicing"
        "TPConnects:AllowedCallbackURLs:0"                 = "https://fcprelivesanitize.tpconnects.online/"
        "WEBSITE_ENABLE_SYNC_UPDATE_SITE"                  = true
        "WEBSITE_RUN_FROM_PACKAGE"                         = 1
      }
      ip_restriction = local.as_ip_restriction
    },
    {
      name                    = "inferno"
      app_service_plan        = local.as_supp_name
      ftps_state              = "Disabled"
      key_vault_public_access = false
      always_on               = true
      app_settings = {
        "ASPNETCORE_ENVIRONMENT"                  = "Development"
        "CachingOptions:AbsoluteExpiration"       = 86400
        "OasisRegions:Regions:0:ConnectionString" = "@Microsoft.KeyVault(SecretUri=https://kv-inferno${var.env}cac.vault.azure.net/secrets/OasisRegionsRegions0ConnectionString/)"
        "OasisRegions:Regions:0:RegionCode"       = "AU"
        "OasisRegions:Regions:1:ConnectionString" = "@Microsoft.KeyVault(SecretUri=https://kv-inferno${var.env}cac.vault.azure.net/secrets/OasisRegionsRegions1ConnectionString/)"
        "OasisRegions:Regions:1:RegionCode"       = "NZ"
        "OasisRegions:Regions:2:ConnectionString" = "@Microsoft.KeyVault(SecretUri=https://kv-inferno${var.env}cac.vault.azure.net/secrets/OasisRegionsRegions2ConnectionString/)"
        "OasisRegions:Regions:2:RegionCode"       = "UK"
        "OasisRegions:Regions:3:ConnectionString" = "@Microsoft.KeyVault(SecretUri=https://kv-inferno${var.env}cac.vault.azure.net/secrets/OasisRegionsRegions3ConnectionString/)"
        "OasisRegions:Regions:3:RegionCode"       = "RSA"
        "XDT_MicrosoftApplicationInsights_Mode"   = "Recommended"
        "WEBSITE_ENABLE_SYNC_UPDATE_SITE"         = true
        "WEBSITE_RUN_FROM_PACKAGE"                = 1
        "Authentication:ApiKey"                   = "@Microsoft.KeyVault(SecretUri=https://kv-inferno${var.env}cac.vault.azure.net/secrets/AuthenticationApiKey/)"
      }
      ip_restriction = local.as_ip_restriction
    },
    {
      name                    = "referencedata"
      app_service_plan        = local.as_supp_name
      ftps_state              = "Disabled"
      key_vault_public_access = false
      always_on               = true
      app_settings = {
        "ASPNETCORE_ENVIRONMENT"                  = "Development"
        "CachingOptions:AbsoluteExpiration"       = 86400
        "OasisRegions:Regions:0:ConnectionString" = "@Microsoft.KeyVault(SecretUri=https://kv-referencedata${var.env}cac.vault.azure.net/secrets/OasisRegionsRegions0ConnectionString/)"
        "OasisRegions:Regions:0:RegionCode"       = "AU"
        "OasisRegions:Regions:1:ConnectionString" = "@Microsoft.KeyVault(SecretUri=https://kv-referencedata${var.env}cac.vault.azure.net/secrets/OasisRegionsRegions1ConnectionString/)"
        "OasisRegions:Regions:1:RegionCode"       = "NZ"
        "OasisRegions:Regions:2:ConnectionString" = "@Microsoft.KeyVault(SecretUri=https://kv-referencedata${var.env}cac.vault.azure.net/secrets/OasisRegionsRegions2ConnectionString/)"
        "OasisRegions:Regions:2:RegionCode"       = "UK"
        "OasisRegions:Regions:3:ConnectionString" = "@Microsoft.KeyVault(SecretUri=https://kv-referencedata${var.env}cac.vault.azure.net/secrets/OasisRegionsRegions3ConnectionString/)"
        "OasisRegions:Regions:3:RegionCode"       = "RSA"
        "XDT_MicrosoftApplicationInsights_Mode"   = "Recommended"
        "WEBSITE_ENABLE_SYNC_UPDATE_SITE"         = true
        "WEBSITE_RUN_FROM_PACKAGE"                = 1
        "Authentication:ApiKey"                   = "@Microsoft.KeyVault(SecretUri=https://kv-referencedata${var.env}cac.vault.azure.net/secrets/AuthenticationApiKey/)"
      }
      ip_restriction = local.as_ip_restriction
    }
  ]
  appi        = { name = module.pme-application-insights.app_insight_name, resourcegroup = module.pme-application-insights.resource_group_name }
  common_tags = var.common_tags
}

resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  for_each       = module.pme-appservice.web_app_id
  app_service_id = each.value
  subnet_id      = module.pme-virtualnetwork.subnet_id["web"]
}
