resource "azurerm_storage_account" "asaccount" {
  for_each                 = local.set_st_name
  name                     = each.key == "platform" ? "st${var.project_name}${each.key}private${var.env_name}" :  "st${var.project_name}${each.key}${var.env_name}"
  resource_group_name      = azurerm_resource_group.rg[each.key].name
  location                 = azurerm_resource_group.rg[each.key].location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = var.env_name,
  }

  blob_properties {
    cors_rule {
      allowed_headers    = [ "*", ]
      allowed_methods    = [ "GET", "OPTIONS", ]
      allowed_origins    = [ "https://portal.${var.custom_domain}", ]
      exposed_headers    = [ "*", ]
      max_age_in_seconds = 200
    }
  }
}

resource "azurerm_storage_account_network_rules" "private" {
  for_each                   = azurerm_storage_account.asaccount
  storage_account_id         = each.value.id
  default_action             = "Allow"
  ip_rules                   = []
  virtual_network_subnet_ids = each.key == "platform" ? [azurerm_subnet.asubnet["vnet-${var.project_name}-backend-${var.env_name}"].id] : [azurerm_subnet.asubnet["vnet-${var.project_name}-frontend-${var.env_name}"].id]
}

resource "azurerm_storage_container" "ascontainer" {
  for_each              = local.map_st_stc_type
  name                  = "${each.value.stc_name}" 
  storage_account_name  = azurerm_storage_account.asaccount[each.value.st_name].name
  container_access_type = each.value.stc_type
}

resource "azurerm_storage_table" "astable" {
  name                 = "BackOfficeUsers"
  storage_account_name = azurerm_storage_account.asaccount["web"].name
}

resource "azurerm_storage_account" "cache" {
  name                     = "st${var.project_name}platformpublic${var.env_name}"
  resource_group_name      = azurerm_resource_group.rg["platform"].name
  location                 = azurerm_resource_group.rg["platform"].location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = var.env_name,
  }

  blob_properties {
    cors_rule {
      allowed_headers    = [ "*", ]
      allowed_methods    = [ "GET", "OPTIONS", ]
      allowed_origins    = [ "https://${var.b2c_candidates_domain}.b2clogin.com", ]
      exposed_headers    = [ "*", ]
      max_age_in_seconds = 200
    }
    cors_rule {
      allowed_headers    = [ "*", ]
      allowed_methods    = [ "GET", "OPTIONS", ]
      allowed_origins    = [ "https://${var.b2c_companies_domain}.b2clogin.com", ]
      exposed_headers    = [ "*", ]
      max_age_in_seconds = 200
    }
  }
}

resource "azurerm_storage_container" "cache" {
  for_each              = var.public_storage_account
  name                  = "${each.key}"
  storage_account_name  = azurerm_storage_account.cache.name
  container_access_type = each.value
}