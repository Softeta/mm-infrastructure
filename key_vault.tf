data "azurerm_client_config" "current" { 
}

resource "azurerm_key_vault" "akvault" {
  name                        = "kv-${var.project_name}-platform-${var.env_name}-01"
  location                    = azurerm_resource_group.rg["platform"].location
  resource_group_name         = azurerm_resource_group.rg["platform"].name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  tags = {
    Environment = var.env_name,
  }
}

resource "azurerm_key_vault_access_policy" "user" {
  key_vault_id = azurerm_key_vault.akvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get",
    "Create",
    "List",
  ]

  secret_permissions = [
    "Get",
    "Backup", 
    "Delete", 
    "Purge",
    "List",
    "Recover",
    "Restore",
    "Set",
  ]

  storage_permissions = [
    "Get",
  ]
}

resource "azurerm_key_vault_access_policy" "frontvnet" {
  for_each     = azurerm_linux_function_app.frontvnet
  key_vault_id = azurerm_key_vault.akvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]

  depends_on = [
    azurerm_key_vault_access_policy.user
  ]
}

resource "azurerm_key_vault_access_policy" "backvnet" {
  for_each     = azurerm_linux_function_app.backvnet
  key_vault_id = azurerm_key_vault.akvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]

  depends_on = [
    azurerm_key_vault_access_policy.user
  ]
}

resource "azurerm_key_vault_access_policy" "planbackend" {
  for_each     = azurerm_linux_web_app.backend
  key_vault_id = azurerm_key_vault.akvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]

  depends_on = [
    azurerm_key_vault_access_policy.user
  ]
}

resource "azurerm_key_vault_access_policy" "slotbackend" {
  for_each     = var.env_name != "dev" ? azurerm_linux_web_app_slot.backend : {}
  key_vault_id = azurerm_key_vault.akvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]

  depends_on = [
    azurerm_key_vault_access_policy.user
  ]
}

resource "azurerm_key_vault_access_policy" "slotapigateway" {
  for_each     = var.env_name != "dev" ? azurerm_linux_web_app_slot.apigateway : {}
  key_vault_id = azurerm_key_vault.akvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]

  depends_on = [
    azurerm_key_vault_access_policy.user
  ]
}  

resource "azurerm_key_vault_access_policy" "planapigateway" {
  for_each     = azurerm_linux_web_app.apigateway
  key_vault_id = azurerm_key_vault.akvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]

  depends_on = [
    azurerm_key_vault_access_policy.user
  ]
}

resource "azurerm_key_vault_access_policy" "plancontainer" {
  for_each     = azurerm_linux_web_app.container
  key_vault_id = azurerm_key_vault.akvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]

  depends_on = [
    azurerm_key_vault_access_policy.user
  ]
}