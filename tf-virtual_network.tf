locals {
  address_space = jsondecode(file("vnet_config/vnet_config-${var.env}.json"))
  nsgr_snet_web_allow = {
    name                       = "snet-web",
    priority                   = 200,
    direction                  = "Inbound",
    access                     = "Allow",
    protocol                   = "*",
    source_port_range          = "*",
    destination_port_range     = "*",
    source_address_prefix      = local.address_space.web_cidr,
    destination_address_prefix = "*"
  }
  nsgr_snet_function_allow = {
    name                       = "snet-function",
    priority                   = 210,
    direction                  = "Inbound",
    access                     = "Allow",
    protocol                   = "*",
    source_port_range          = "*",
    destination_port_range     = "*",
    source_address_prefix      = local.address_space.function_cidr,
    destination_address_prefix = "*"
  }
  nsgr_default_deny = {
    name                       = "default",
    priority                   = 4000,
    direction                  = "Inbound",
    access                     = "Deny",
    protocol                   = "*",
    source_port_range          = "*",
    destination_port_range     = "*",
    source_address_prefix      = "*",
    destination_address_prefix = "*"
  }
}

module "pme-virtualnetwork" {
  source         = "app.terraform.io/flight-centre/pme-virtualnetwork/azurerm"
  version        = "0.0.34"
  resource_group = azurerm_resource_group.rg.name
  location       = azurerm_resource_group.rg.location
  env            = var.env
  vnet = {
    name          = "airlink",
    address_space = [local.address_space.vnet_cidr]
  }
  subnet = [
    {
      name             = "web",
      address_prefixes = [local.address_space.web_cidr],
      delegation = {
        action             = ["Microsoft.Network/virtualNetworks/subnets/action"],
        service_delegation = "Microsoft.Web/serverFarms"
      },
      net_security_group = {
        security_rule = []
      }
    },
    {
      name             = "function",
      address_prefixes = [local.address_space.function_cidr],
      delegation = {
        action             = ["Microsoft.Network/virtualNetworks/subnets/action"],
        service_delegation = "Microsoft.Web/serverFarms"
      },
      net_security_group = {
        security_rule = []
      }
    },
    {
      name             = "cosmos",
      address_prefixes = [local.address_space.cosmos_cidr],
      net_security_group = {
        security_rule = [
          local.nsgr_snet_web_allow,
          local.nsgr_snet_function_allow,
          local.nsgr_default_deny
        ]
      }
    },
    {
      name             = "storage",
      address_prefixes = [local.address_space.storage_cidr],
      net_security_group = {
        security_rule = [
          local.nsgr_snet_function_allow,
          local.nsgr_default_deny
        ]
      }
    },
    {
      name              = "applications",
      address_prefixes  = [local.address_space.applications_cidr],
      service_endpoints = ["Microsoft.Web"]
      net_security_group = {
        security_rule = [
          local.nsgr_snet_web_allow,
          local.nsgr_snet_function_allow,
          local.nsgr_default_deny
        ]
      }
    },
    {
      name             = "management",
      address_prefixes = [local.address_space.management_cidr],
      net_security_group = {
        security_rule = [
          local.nsgr_default_deny
        ]
      }
    },
    {
      name             = "keyvault",
      address_prefixes = [local.address_space.keyvault_cidr],
      net_security_group = {
        security_rule = [
          local.nsgr_snet_web_allow,
          local.nsgr_snet_function_allow,
          local.nsgr_default_deny
        ]
      }
    },
    {
      name             = "networking",
      address_prefixes = [local.address_space.network_cidr],
      net_security_group = {
        security_rule = []
      }
    },
    {
      name             = "pdr_outbound",
      address_prefixes = [local.address_space.pdr_outbound_cdir],
      delegation = {
        action             = ["Microsoft.Network/virtualNetworks/subnets/join/action"],
        service_delegation = "Microsoft.Network/dnsResolvers"
      },
      net_security_group = {
        security_rule = []
      }
    },
  ]
}
