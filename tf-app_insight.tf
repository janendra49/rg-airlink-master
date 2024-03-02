module "pme-application-insights" {
  source             = "app.terraform.io/flight-centre/pme-application-insights/azurerm"
  version            = "0.0.6"
  resource_group     = azurerm_resource_group.rg.name
  location           = azurerm_resource_group.rg.location
  env                = var.env
  project_name       = "airlink"
  law_sku            = "PerGB2018"
  retention_in_days  = 90
  appi_type          = "web"
  private_link_scope = true
}
