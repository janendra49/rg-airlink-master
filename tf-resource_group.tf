provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-airlink-${var.env}"
  location = "canadacentral"
  tags     = var.common_tags
}
