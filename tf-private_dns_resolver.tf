module "pme-private_dns_resolver" {
  source              = "app.terraform.io/flight-centre/pme-private_dns_resolver/azurerm"
  version             = "0.0.1"
  name                = "airlink"
  resource_group_name = azurerm_resource_group.rg.name
  environment         = var.env
  virtual_network_id  = module.pme-virtualnetwork.vnet_id
  outbound_subnet_id  = module.pme-virtualnetwork.subnet_id["pdr_outbound"]
  forward_rule = {
    "au_fcl_internal" = {
      domain_name = "au.fcl.internal."
      target_dns_servers = [
        "10.22.236.29",
        "10.22.238.29",
        "10.27.236.35",
        "10.27.236.70",
        "10.27.238.29"
      ]
    }
  }
  depends_on = [module.pme-virtualnetwork.vnet_id]
}
