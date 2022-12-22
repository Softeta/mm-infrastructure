
resource "azurerm_resource_group" "tfstate" {
  name      = "rg-${var.project_name}-tfstate-${var.env_state}"
  location  = var.resource_group_location
}

resource "azurerm_storage_account" "tfstate" {
  name                      = "st${var.project_name}tfstate${var.env_state}"
  resource_group_name       = azurerm_resource_group.tfstate.name
  location                  = azurerm_resource_group.tfstate.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  access_tier               = "Cool"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"

  tags = {
    environment = var.env_state
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "stc${var.project_name}tfstate${var.env_state}"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

resource "azurerm_storage_encryption_scope" "tfstate" {
  name               = "microsoftmanaged"
  storage_account_id = azurerm_storage_account.tfstate.id
  source             = "Microsoft.Storage"
}