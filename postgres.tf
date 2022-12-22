resource "azurerm_postgresql_server" "psqlserver" {
  for_each            = local.map_psql_name
  name                = "psql-${var.project_name}-${each.value.psql_name}-${var.env_name}"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg[each.key].name

  administrator_login          = "MM${each.value.psql_name}Admin"
  administrator_login_password = random_password.psqldbpassword[each.key].result

  sku_name   = "GP_Gen5_2"
  version    = "11"
  storage_mb = 10240

  backup_retention_days        = 7
  geo_redundant_backup_enabled = true
  auto_grow_enabled            = true

  public_network_access_enabled    = true
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"

  tags = {
    Environment = var.env_name,
  }
}

resource "azurerm_postgresql_database" "psqldb" {
  for_each            = local.map_psql_name
  name                = "psqldb-${var.project_name}-${each.value.psql_name}-${var.env_name}"
  resource_group_name = azurerm_resource_group.rg[each.key].name
  server_name         = azurerm_postgresql_server.psqlserver[each.key].name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_firewall_rule" "AllowAllWindowsAzureIps" {
  for_each            = azurerm_postgresql_server.psqlserver
  name                = "AllowAllWindowsAzureIps"
  resource_group_name = azurerm_resource_group.rg[each.key].name
  server_name         = azurerm_postgresql_server.psqlserver[each.key].name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_postgresql_virtual_network_rule" "amvnrule" {
  for_each            = azurerm_postgresql_server.psqlserver
  name                = "psql-vnet-${each.key}-rule"
  resource_group_name = azurerm_resource_group.rg[each.key].name
  server_name         = azurerm_postgresql_server.psqlserver[each.key].name
  subnet_id           = azurerm_subnet.asubnet["vnet-${var.project_name}-backend-${var.env_name}"].id
}