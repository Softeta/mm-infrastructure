resource "azurerm_resource_group" "rg" {
  for_each  = var.sqs_data
  name      = "rg-${var.project_name}-${each.value.rg_name}-${var.env_name}"
  location  = var.resource_group_location

  tags = {
    Environment = var.env_name,
  }
}

//Future improvement to create static app enabled key
resource "azurerm_static_site" "web" {
  name                = "stapp-${var.project_name}-web-${var.env_name}"
  resource_group_name = azurerm_resource_group.rg["web"].name
  location            = "westeurope"

  depends_on = [
    azurerm_service_plan.asplan
  ]

  tags = {
    Environment = var.env_name,
  }
}

resource "azurerm_static_site" "selfservice" {
  name                = "stapp-${var.project_name}-selfservice-${var.env_name}"
  resource_group_name = azurerm_resource_group.rg["web"].name
  location            = "westeurope"

  depends_on = [
    azurerm_service_plan.asplan
  ]

  tags = {
    Environment = var.env_name,
  }
}

resource "azurerm_log_analytics_workspace" "alaworkspace" {
  name                = "log-${var.project_name}-workspace-${var.env_name}"
  resource_group_name = azurerm_resource_group.rg["platform"].name
  location            = azurerm_resource_group.rg["platform"].location
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Environment = var.env_name,
  }
}

resource "azurerm_search_service" "asservice" {
  for_each             = local.map_srch_name
  name                 = "srch-${var.project_name}-${each.value.srch_name}-${var.env_name}"
  resource_group_name  = azurerm_resource_group.rg[each.key].name
  location             = azurerm_resource_group.rg[each.key].location
  sku                  = "standard"

  tags = {
    Environment = var.env_name,
  }
}
