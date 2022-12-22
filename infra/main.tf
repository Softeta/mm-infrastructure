resource "azurerm_resource_group" "rg" {
  name      = "rg-${var.project_name}-infra-${var.env_state}"
  location  = var.resource_group_location
}

/*resource "azurerm_aadb2c_directory" "mm" {
  country_code            = "DK"
  data_residency_location = "Europe"
  display_name            = "Holm Marcher ${var.env_state}"
  domain_name             = "holmmarcher${var.env_state}.onmicrosoft.com"
  resource_group_name     = azurerm_resource_group.rg.name
  sku_name                = "PremiumP1"
}*/