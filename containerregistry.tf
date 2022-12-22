resource "azurerm_container_registry" "acr" {
  for_each            = local.map_cr_name
  name                = "cr${var.project_name}${each.value.cr_name}${var.env_name}"
  resource_group_name = azurerm_resource_group.rg[each.key].name
  location            = var.resource_group_location
  sku                 = "Basic"
  admin_enabled       = true

  tags = {
    Environment = var.env_name,
  }
}
