variable "fa_asp_sku" {
  type = string
}

variable "st_replication" {
  type = string
}

locals {
  fa_supp_name = "airlinkfunc"
}

module "pme-function-apps" {
  source      = "app.terraform.io/flight-centre/pme-function-apps/azurerm"
  version     = "4.2.0"
  rg_name     = azurerm_resource_group.rg.name
  env         = var.env
  common_tags = var.common_tags
  appi        = { name = module.pme-application-insights.app_insight_name, resourcegroup = module.pme-application-insights.resource_group_name }
  storage_account = [{
    name                      = local.fa_supp_name
    account_tier              = "Standard"
    account_replication_type  = var.st_replication
    min_tls_version           = "TLS1_2"
    shared_access_key_enabled = true
    public_access             = false
  }]
  app_service_plan = [{
    name    = local.fa_supp_name
    os_type = "Windows"
    sku     = var.fa_asp_sku
  }]
  function_app = [
    {
      name                    = "airlink"
      storage                 = local.fa_supp_name
      app_service_plan        = local.fa_supp_name
      key_vault_public_access = false
      always_on               = true
      client_certificate_mode = "Required"
      app_settings = {
        "CosmosDatabase:ConnectionString"               = "@Microsoft.KeyVault(SecretUri=https://kv-airlink${var.env}cac.vault.azure.net/secrets/CosmosDatabaseConnectionString/)",
        "CosmosDatabase:ContainerDefaultTimeToLiveDays" = "90",
        "CosmosDatabase:DatabaseName"                   = "cosmos-airlink-entities",
        "Inferno:BaseUrl"                               = "https://wa-inferno-${var.env}-cac.azurewebsites.net",
        "Inferno:SubscriptionKey"                       = "@Microsoft.KeyVault(SecretUri=https://kv-airlink${var.env}cac.vault.azure.net/secrets/InfernoSubscriptionKey/)",
        "OasisServices:Regions:0:EndpointUrl"           = "https://oasis-${var.env}-au.au.fcl.internal/OasisServices",
        "OasisServices:Regions:0:RegionCode"            = "AU",
        "OasisServices:Regions:0:ValidationKey"         = "@Microsoft.KeyVault(SecretUri=https://kv-airlink${var.env}cac.vault.azure.net/secrets/OasisServicesRegions0ValidationKey/)",
        "OasisServices:Regions:1:EndpointUrl"           = "https://oasis-${var.env}-nz.au.fcl.internal/OasisServices",
        "OasisServices:Regions:1:RegionCode"            = "NZ",
        "OasisServices:Regions:1:ValidationKey"         = "@Microsoft.KeyVault(SecretUri=https://kv-airlink${var.env}cac.vault.azure.net/secrets/OasisServicesRegions1ValidationKey/)",
        "OasisServices:Regions:2:EndpointUrl"           = "https://oasis-${var.env}-uk.au.fcl.internal/OasisServices",
        "OasisServices:Regions:2:RegionCode"            = "UK",
        "OasisServices:Regions:2:ValidationKey"         = "@Microsoft.KeyVault(SecretUri=https://kv-airlink${var.env}cac.vault.azure.net/secrets/OasisServicesRegions2ValidationKey/)",
        "OasisServices:Regions:3:EndpointUrl"           = "https://oasis-${var.env}-rsa.au.fcl.internal/OasisServices",
        "OasisServices:Regions:3:RegionCode"            = "RSA",
        "OasisServices:Regions:3:ValidationKey"         = "@Microsoft.KeyVault(SecretUri=https://kv-airlink${var.env}cac.vault.azure.net/secrets/OasisServicesRegions3ValidationKey/)",
        "ReferenceData:BaseUrl"                         = "https://wa-referencedata-${var.env}-cac.azurewebsites.net",
        "ReferenceData:SubscriptionKey"                 = "@Microsoft.KeyVault(SecretUri=https://kv-airlink${var.env}cac.vault.azure.net/secrets/ReferenceDataSubscriptionKey/)",
        "TpcClient:Instances:0:ApiKey"                  = "@Microsoft.KeyVault(SecretUri=https://kv-airlink${var.env}cac.vault.azure.net/secrets/TpcClientInstances0ApiKey/)",
        "TpcClient:Instances:0:ApiSecret"               = "@Microsoft.KeyVault(SecretUri=https://kv-airlink${var.env}cac.vault.azure.net/secrets/TpcClientInstances0ApiSecret/)",
        "TpcClient:Instances:0:Url"                     = "https://fcprelivesanitize.tpconnects.online/",
        # "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING"      = "@Microsoft.KeyVault(SecretUri=https://kv-airlink${var.env}cac.vault.azure.net/secrets/WEBSITECONTENTAZUREFILECONNECTIONSTRING/)",
        # "WEBSITE_CONTENTOVERVNET"                       = 1,
        # "WEBSITE_CONTENTSHARE"                          = "func-airlink-${var.env}-cac-001",
        "WEBSITE_ENABLE_SYNC_UPDATE_SITE" = true,
        "WEBSITE_RUN_FROM_PACKAGE"        = 1
      }
      ip_restriction = [
        {
          action                    = "Allow"
          name                      = "snet-application"
          priority                  = 100
          virtual_network_subnet_id = module.pme-virtualnetwork.subnet_id["applications"]
        },
        {
          action      = "Allow"
          name        = "AzureDevOps"
          priority    = 110
          service_tag = "AzureDevOps"
        },
        {
          action     = "Allow"
          name       = "office network"
          priority   = 120
          ip_address = "116.50.58.0/24"
        }
      ]
    }
  ]
}

resource "azurerm_app_service_virtual_network_swift_connection" "funcapp-vnet_integration" {
  app_service_id = module.pme-function-apps.function_app_id["airlink"]
  subnet_id      = module.pme-virtualnetwork.subnet_id["function"]
}
