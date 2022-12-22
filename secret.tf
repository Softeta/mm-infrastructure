#Create KeyVault DB password
resource "random_password" "dbpassword" {
  for_each = local.map_sql_name
  length = 20
  special = true
}

resource "azurerm_key_vault_secret" "sqldb" {
  for_each     = local.map_sql_name
  name         = "sqldb-${var.project_name}-${each.value.sql_name}"
  value        = "Server=tcp:${azurerm_mssql_server.sqlserver[each.value.sql_name].fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.sqldb[each.value.sql_name].name};Persist Security Info=False;User ID=${azurerm_mssql_server.sqlserver[each.value.sql_name].administrator_login};Password=${random_password.dbpassword[each.key].result};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.akvault.id

  depends_on = [
    azurerm_key_vault_access_policy.user
  ]
}

resource "random_password" "psqldbpassword" {
  for_each = local.map_psql_name
  length = 20
  special = true
}

resource "azurerm_key_vault_secret" "psqldb" {
  for_each     = local.map_psql_name
  name         = "psqldb-${var.project_name}-${each.value.psql_name}"
  value        = "psql://${azurerm_postgresql_server.psqlserver[each.value.psql_name].administrator_login}:${random_password.psqldbpassword[each.key].result}@${azurerm_postgresql_server.psqlserver[each.value.psql_name].fqdn}:5432/${azurerm_postgresql_database.psqldb[each.value.psql_name].name}"
  key_vault_id = azurerm_key_vault.akvault.id

  depends_on = [
    azurerm_key_vault_access_policy.user
  ]
}

resource "azurerm_key_vault_secret" "psqldbpassword" {
  for_each     = local.map_psql_name
  name         = "psqldbpassword-${var.project_name}-${each.value.psql_name}"
  value        = random_password.psqldbpassword[each.key].result
  key_vault_id = azurerm_key_vault.akvault.id

  depends_on = [
    azurerm_key_vault_access_policy.user
  ]
}

resource "azurerm_key_vault_secret" "sbsas" {
  for_each     = azurerm_servicebus_namespace_authorization_rule.sasservice
  name         = "sb-${each.value.name}"
  value        = each.value.primary_connection_string
  key_vault_id = azurerm_key_vault.akvault.id

  depends_on = [
    azurerm_key_vault_access_policy.user
  ]
}

resource "azurerm_key_vault_secret" "storage" {
  for_each     = azurerm_storage_account.asaccount
  name         = "${each.value.name}-key"
  value        = each.value.primary_access_key
  key_vault_id = azurerm_key_vault.akvault.id

  depends_on = [
    azurerm_key_vault_access_policy.user
  ]
}

resource "azurerm_key_vault_secret" "platform-private" {
  name         = "private-storage-account-key"
  value        = azurerm_storage_account.asaccount["platform"].primary_access_key
  key_vault_id = azurerm_key_vault.akvault.id

  depends_on = [
    azurerm_key_vault_access_policy.user
  ]
}

resource "azurerm_key_vault_secret" "platform-public" {
  name         = "public-storage-account-key"
  value        = azurerm_storage_account.cache.primary_access_key
  key_vault_id = azurerm_key_vault.akvault.id

  depends_on = [
    azurerm_key_vault_access_policy.user
  ]
}

resource "azurerm_key_vault_secret" "web" {
  name         = "web-storage-account-key"
  value        = azurerm_storage_account.asaccount["web"].primary_access_key
  key_vault_id = azurerm_key_vault.akvault.id

  depends_on = [
    azurerm_key_vault_access_policy.user
  ]
}

resource "azurerm_key_vault_secret" "searchservice" {
  for_each     = local.map_srch_name
  name         = "srch-${var.project_name}-${each.value.srch_name}-admin-key"
  value        = azurerm_search_service.asservice[each.value.srch_name].primary_key
  key_vault_id = azurerm_key_vault.akvault.id
  
  depends_on = [
    azurerm_key_vault_access_policy.user
  ]
}

resource "azurerm_key_vault_secret" "backoffice" {
  name         = "backoffice-app-registration-secret"
  value        = azuread_application_password.pwd.value
  key_vault_id = azurerm_key_vault.akvault.id

  depends_on = [
    azurerm_key_vault_access_policy.user
  ]
}

resource "azurerm_key_vault_secret" "sendinblue" {
  name         = "send-in-blue-api-key"
  value        = var.secret_sendinblue
  key_vault_id = azurerm_key_vault.akvault.id

  depends_on = [
    azurerm_key_vault_access_policy.user
  ]
}

resource "azurerm_key_vault_secret" "heresearch" {
  name         = "here-search-api-key"
  value        = var.secret_heresearch
  key_vault_id = azurerm_key_vault.akvault.id

  depends_on = [
    azurerm_key_vault_access_policy.user
  ]
}

resource "azurerm_key_vault_secret" "talogy" {
  name         = "talogy-api-client-secret"
  value        = var.secret_talogy
  key_vault_id = azurerm_key_vault.akvault.id

  depends_on = [
    azurerm_key_vault_access_policy.user
  ]
}

resource "azurerm_key_vault_secret" "candidate" {
  name         = "candidate-app-registration-secret"
  value        = var.secret_candidate
  key_vault_id = azurerm_key_vault.akvault.id
  
  depends_on = [
    azurerm_key_vault_access_policy.user
  ]
}

resource "azurerm_key_vault_secret" "company" {
  name         = "company-app-registration-secret"
  value        = var.secret_company
  key_vault_id = azurerm_key_vault.akvault.id
  
  depends_on = [
    azurerm_key_vault_access_policy.user
  ]
}

resource "azurerm_key_vault_secret" "danishcrv" {
  name         = "danish-crv-api-user-password"
  value        = var.secret_danishcrv
  key_vault_id = azurerm_key_vault.akvault.id
  
  depends_on = [
    azurerm_key_vault_access_policy.user
  ]
}

resource "azurerm_key_vault_secret" "weawy" {
  name         = "weawy-api-secret"
  value        = var.secret_weawy
  key_vault_id = azurerm_key_vault.akvault.id

  depends_on = [
    azurerm_key_vault_access_policy.user
  ]
}

resource "azurerm_key_vault_secret" "formrecognizer" {
  name         = "candidates-cv-parser-form-recognizer-key"
  value        = var.secret_formrecognizerkey
  key_vault_id = azurerm_key_vault.akvault.id
  
  depends_on = [
    azurerm_key_vault_access_policy.user
  ]
}
