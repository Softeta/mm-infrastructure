resource "azurerm_resource_group" "network" {
  name      = "rg-${var.project_name}-network-${var.env_name}"
  location  = var.resource_group_location

  tags = {
    Environment = var.env_name,
  }
}

module "subnet_addrs" {
  source = "hashicorp/subnets/cidr"
  base_cidr_block = "10.${var.subnet[var.env_name]}.0.0/16"
  networks = local.network_block_legacy
}

/*
module "subnet_addrs" {
  source = "hashicorp/subnets/cidr"
  base_cidr_block = "10.0.0.0/16"
  networks = local.network_block
}
*/

resource "azurerm_network_security_group" "azsgroup" {
  name                = "sgroup-${var.project_name}-infra-${var.env_name}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name

  tags = {
    Environment = var.env_name,
  }
}

resource "azurerm_virtual_network" "avnetwork" {
  name                = "vnet-${var.project_name}-infra-${var.env_name}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = ["10.${var.subnet[var.env_name]}.0.0/16"]
  
/*
  dynamic "subnet" {
      for_each = module.subnet_addrs.network_cidr_blocks
      content {
          name     = subnet.key
          address_prefix = subnet.value          
      } 
  }*/

  tags = {
    environment = var.env_name
  }
}

resource "azurerm_subnet" "asubnet" {
  for_each             = module.subnet_addrs.network_cidr_blocks
  name                 = each.key
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.avnetwork.name
  address_prefixes     = [each.value]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage", "Microsoft.Web"]

  delegation {
    name = "app-plan"

  service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

/*
resource "azurerm_subnet" "asubnet" {
  for_each             = module.subnet_addrs.network_cidr_blocks
  name                 = each.key
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.avnetwork.name
  address_prefixes     = each.value
} */