resource "azurerm_mssql_server" "sqlserver" {
  for_each                      = local.map_sql_name
  name                          = "sql-${var.project_name}-${each.value.sql_name}-${var.env_name}"
  resource_group_name           = azurerm_resource_group.rg[each.key].name
  location                      = var.resource_group_location
  version                       = "12.0"
  administrator_login           = "MM${each.value.sql_name}Admin"
  administrator_login_password  = random_password.dbpassword[each.key].result
  public_network_access_enabled = true

  tags = {
    Environment = var.env_name,
  }

  azuread_administrator {
    login_username = "MM Platform Support"
    object_id      = "25e11686-7652-4e07-b7e7-5f78965bc180"
  }

}

resource "azurerm_mssql_database" "sqldb" {
  for_each             = local.map_sql_name
  name                 = "sqldb-${var.project_name}-${each.value.sql_name}-${var.env_name}"
  server_id            = azurerm_mssql_server.sqlserver[each.key].id
  max_size_gb          = local.sqlskuplans[each.key].sku_name == "Basic" ? 1 : 250
  sku_name             = local.sqlskuplans[each.key].sku_name
  zone_redundant       = false
 // geo_backup_enabled   = false is only applicable for DataWarehouse SKUs (DW*). This setting is ignored for all other SKUs.
  storage_account_type = "Local"

  tags = {
    Environment = var.env_name,
  }
}

resource "azurerm_mssql_firewall_rule" "AllowAllWindowsAzureIps" {
  for_each  = azurerm_mssql_server.sqlserver
  name             = "AllowAllWindowsAzureIps"
  server_id        = each.value.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_virtual_network_rule" "amvnrule" {
  for_each  = azurerm_mssql_server.sqlserver
  name      = "sql-vnet-${each.key}-rule"
  server_id = each.value.id
  subnet_id = azurerm_subnet.asubnet["vnet-${var.project_name}-backend-${var.env_name}"].id
}