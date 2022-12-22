resource "azurerm_service_plan" "asplan" {
  for_each            = toset(local.serviceplan)
  name                = "plan-${var.project_name}-${each.key}-${var.env_name}"
  resource_group_name = azurerm_resource_group.rg[each.key].name
  location            = azurerm_resource_group.rg[each.key].location
  sku_name            = local.skuserviceplan[each.key].sku_name
  worker_count        = var.env_name == "dev" ? 3 : 2 
  os_type             = "Linux"

  tags = {
    Environment = var.env_name,
  }
}

resource "azurerm_linux_web_app" "backend" {
  for_each            = { for k, v in local.map_rg_app_name: k => v if v.plan_name == "platform" }
  name                = "app-${var.project_name}-${each.value.app_name}-${var.env_name}"
  resource_group_name = azurerm_resource_group.rg[each.value.rg_name].name
  location            = azurerm_resource_group.rg[each.value.rg_name].location
  service_plan_id     = azurerm_service_plan.asplan[each.value.plan_name].id
  https_only          = false

  tags = {
    Environment = var.env_name,
  }

  site_config {
    always_on                         = var.env_name == "sand" ? false : true
    health_check_path                 = "/api/health"
    health_check_eviction_time_in_min = 2
    worker_count                      = var.env_name == "dev" ? 3 : 2
     
    application_stack {
      dotnet_version = "6.0"
    }
  }
 
  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      app_settings
    ]
  }
}

resource "azurerm_linux_web_app_slot" "backend" {
  for_each       = ( var.env_name == "sand" ?
                       {} : (
                       var.env_name == "dev" ? 
                         {} :
                         azurerm_linux_web_app.backend
                       )
                   )
  name           = "stage"
  app_service_id = each.value.id

  site_config {
    always_on                         = false
    health_check_path                 = "/api/health"
     
    application_stack {
      dotnet_version = "6.0"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      app_settings
    ]
  }
}

resource "azurerm_linux_web_app" "apigateway" {
  for_each            = { for k, v in local.map_rg_app_name: k => v if v.plan_name == "web" }
  name                = "app-${var.project_name}-${each.value.app_name}-${var.env_name}"
  resource_group_name = azurerm_resource_group.rg[each.value.rg_name].name
  location            = azurerm_resource_group.rg[each.value.rg_name].location
  service_plan_id     = azurerm_service_plan.asplan[each.value.plan_name].id
  https_only          = false

  tags = {
    Environment = var.env_name,
  }

  site_config {
    always_on = var.env_name == "sand" ? false : true
    vnet_route_all_enabled = true
    health_check_path                 = "/api/health"
    health_check_eviction_time_in_min = 2
    worker_count                      = var.env_name == "dev" ? 3 : 2

    application_stack {
      dotnet_version = "6.0"
    }
  }
 
  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      app_settings
    ]
  }
}

resource "azurerm_linux_web_app_slot" "apigateway" {
  for_each       = ( var.env_name == "sand" ?
                       {} : (
                       var.env_name == "dev" ? 
                         {} :
                         azurerm_linux_web_app.apigateway
                       )
                   )
  name           = "stage"
  app_service_id = each.value.id

  site_config {
    always_on                         = false
    health_check_path                 = "/api/health"
     
    application_stack {
      dotnet_version = "6.0"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      app_settings
    ]
  }
}

resource "azurerm_linux_web_app" "container" {
  for_each            = { for k, v in local.map_rg_container_app_name: k => v if v.plan_name == "web" }
  name                = "app-${var.project_name}-${each.value.app_container_name}-${var.env_name}"
  resource_group_name = azurerm_resource_group.rg[each.value.rg_name].name
  location            = azurerm_resource_group.rg[each.value.rg_name].location
  service_plan_id     = azurerm_service_plan.asplan[each.value.plan_name].id
  https_only          = false

  tags = {
    Environment = var.env_name,
  }

  site_config {
    always_on = var.env_name == "sand" ? false : true
    vnet_route_all_enabled = true

    application_stack {
      docker_image = "${azurerm_container_registry.acr["platform"].login_server}/${each.value.container_image}"
      docker_image_tag = "latest"
    }

  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      app_settings,
      site_config[0].application_stack[0].docker_image_tag
    ]
  }
}

resource "azurerm_linux_web_app" "worker" {
  for_each            = { for k, v in local.map_rg_container_app_name: k => v if v.plan_name == "platform" }
  name                = "app-${var.project_name}-${each.value.app_container_name}-${var.env_name}"
  resource_group_name = azurerm_resource_group.rg[each.value.rg_name].name
  location            = azurerm_resource_group.rg[each.value.rg_name].location
  service_plan_id     = azurerm_service_plan.asplan[each.value.plan_name].id
  https_only          = false

  tags = {
    Environment = var.env_name,
  }

  site_config {
    always_on = true
    vnet_route_all_enabled = true

    application_stack {
      docker_image = "${azurerm_container_registry.acr["platform"].login_server}/${each.value.container_image}"
      docker_image_tag = "latest"
    }

  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      app_settings,
      site_config[0].application_stack[0].docker_image_tag
    ]
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "backend" {
  for_each       = azurerm_linux_web_app.backend
  app_service_id = each.value.id
  subnet_id      = azurerm_subnet.asubnet["vnet-${var.project_name}-backend-${var.env_name}"].id
}

resource "azurerm_app_service_virtual_network_swift_connection" "apigateway" {
  for_each       = azurerm_linux_web_app.apigateway
  app_service_id = each.value.id
  subnet_id      = azurerm_subnet.asubnet["vnet-${var.project_name}-frontend-${var.env_name}"].id
}

resource "azurerm_service_plan" "asplanfunc" {
  for_each            = { for k, v in local.funcserviceplan: k => v }
  name                = "planf-${var.project_name}-${each.key}-${var.env_name}"
  resource_group_name = azurerm_resource_group.rg[each.value.rg_name].name
  location            = azurerm_resource_group.rg[each.value.rg_name].location
  sku_name            = "B1"
  os_type             = "Linux"

  tags = {
    Environment = var.env_name,
  }
}

resource "azurerm_linux_function_app" "frontvnet" {
  for_each            = { for k, v in local.map_plan_func_name: k => v if v.func_name != "elastic-search-sync" && v.func_name != "email-service-webhook" }
  name                = "func-${var.project_name}-${each.value.func_name}-${var.env_name}"
  resource_group_name = azurerm_resource_group.rg[each.value.rg_name].name
  location            = azurerm_resource_group.rg[each.value.rg_name].location

  storage_account_name = azurerm_storage_account.asaccount["platform"].name
  service_plan_id      = azurerm_service_plan.asplan[each.value.plan_name].id

  storage_account_access_key    = azurerm_storage_account.asaccount["platform"].primary_access_key

  tags = {
    Environment = var.env_name,
  }

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on = var.env_name == "sand" ? false : true
    application_stack {
      dotnet_version  = "6.0"
    }

    application_insights_connection_string  = azurerm_application_insights.apinsights.connection_string
    application_insights_key                = azurerm_application_insights.apinsights.instrumentation_key
    
    scm_use_main_ip_restriction             = false
    ip_restriction = [
        {
        ip_address = null
        name = null
        action = "Allow"
        virtual_network_subnet_id = azurerm_subnet.asubnet["vnet-${var.project_name}-frontend-${var.env_name}"].id
        priority = "400"
        service_tag = null
        headers = null
        }
    ]
  }

  lifecycle {
    ignore_changes = [
      app_settings
    ]
  }
}

resource "azurerm_linux_function_app" "backvnet" {
  for_each            = { for k, v in local.map_plan_func_name: k => v if v.func_name == "elastic-search-sync" }
  name                = "func-${var.project_name}-${each.value.func_name}-${var.env_name}"
  resource_group_name = azurerm_resource_group.rg[each.value.rg_name].name
  location            = azurerm_resource_group.rg[each.value.rg_name].location

  storage_account_name = azurerm_storage_account.asaccount["platform"].name
  service_plan_id      = azurerm_service_plan.asplan[each.value.plan_name].id

  storage_account_access_key    = azurerm_storage_account.asaccount["platform"].primary_access_key

  tags = {
    Environment = var.env_name,
  }

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on = var.env_name == "sand" ? false : true
    application_stack {
      dotnet_version  = "6.0"
    }

    application_insights_connection_string  = azurerm_application_insights.apinsights.connection_string
    application_insights_key                = azurerm_application_insights.apinsights.instrumentation_key
    
    scm_use_main_ip_restriction             = false
    ip_restriction = [
        {
        ip_address = null
        name = null
        action = "Allow"
        virtual_network_subnet_id = azurerm_subnet.asubnet["vnet-${var.project_name}-backend-${var.env_name}"].id
        priority = "400"
        service_tag = null
        headers = null
        }
    ]
  }

  lifecycle {
    ignore_changes = [
      app_settings
    ]
  }
}

# TODO: #3411 Update IP addresses for DEV and TEST env
resource "azurerm_linux_function_app" "emailservice" {
  for_each            = { for k, v in local.map_plan_func_name: k => v if  v.func_name == "email-service-webhook" }
  name                = "func-${var.project_name}-${each.value.func_name}-${var.env_name}"
  resource_group_name = azurerm_resource_group.rg[each.value.rg_name].name
  location            = azurerm_resource_group.rg[each.value.rg_name].location

  storage_account_name = azurerm_storage_account.asaccount["platform"].name
  service_plan_id      = azurerm_service_plan.asplan[each.value.plan_name].id

  storage_account_access_key    = azurerm_storage_account.asaccount["platform"].primary_access_key

  tags = {
    Environment = var.env_name,
  }

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on = var.env_name == "sand" ? false : true
    application_stack {
      dotnet_version  = "6.0"
    }

    application_insights_connection_string  = azurerm_application_insights.apinsights.connection_string
    application_insights_key                = azurerm_application_insights.apinsights.instrumentation_key
    
    scm_use_main_ip_restriction             = false
    ip_restriction = [
        {
        ip_address = "1.179.112.0/20"
        name = "Send in Blue ERROR"
        action = "Allow"
        virtual_network_subnet_id = null
        priority = "400"
        service_tag = null
        headers = null
        },
        {
        ip_address = "185.107.232.0/24"
        name = "Send in Blue main"
        action = "Allow"
        virtual_network_subnet_id = null
        priority = "400"
        service_tag = null
        headers = null
        }
    ]
  }

  lifecycle {
    ignore_changes = [
      app_settings
    ]
  }
}

resource "azurerm_linux_function_app" "timetriggers" {
  for_each            = { for k, v in local.map_time_trigger_plan_func_name: k => v }
  name                = "func-${var.project_name}-${each.value.func_name}-${var.env_name}"
  resource_group_name = azurerm_resource_group.rg[each.value.rg_name].name
  location            = azurerm_resource_group.rg[each.value.rg_name].location

  storage_account_name = azurerm_storage_account.asaccount["platform"].name
  service_plan_id      = azurerm_service_plan.asplanfunc[each.value.plan_name].id

  storage_account_access_key    = azurerm_storage_account.asaccount["platform"].primary_access_key

  tags = {
    Environment = var.env_name,
  }

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on = var.env_name == "sand" ? false : true
    application_stack {
      dotnet_version  = "6.0"
    }

    application_insights_connection_string  = azurerm_application_insights.apinsights.connection_string
    application_insights_key                = azurerm_application_insights.apinsights.instrumentation_key
    
    scm_use_main_ip_restriction             = false
    ip_restriction = [
        {
        ip_address = null
        name = null
        action = "Allow"
        virtual_network_subnet_id = azurerm_subnet.asubnet["vnet-${var.project_name}-frontend-${var.env_name}"].id
        priority = "400"
        service_tag = null
        headers = null
        }
    ]
  }

  lifecycle {
    ignore_changes = [
      app_settings
    ]
  }
}

resource "azurerm_linux_function_app" "tagsservice" {
  for_each            = { for k, v in local.map_plan_with_own_func_name: k => v if v.func_name == "tags-jobs-created" }
  name                = "func-${var.project_name}-${each.value.func_name}-${var.env_name}"
  resource_group_name = azurerm_resource_group.rg[each.value.rg_name].name
  location            = azurerm_resource_group.rg[each.value.rg_name].location

  storage_account_name = azurerm_storage_account.asaccount["platform"].name
  service_plan_id      = azurerm_service_plan.asplanfunc[each.value.plan_name].id

  storage_account_access_key    = azurerm_storage_account.asaccount["platform"].primary_access_key

  tags = {
    Environment = var.env_name,
  }

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on = var.env_name == "sand" ? false : true
    application_stack {
      python_version = "3.9"
    }

    application_insights_connection_string  = azurerm_application_insights.apinsights.connection_string
    application_insights_key                = azurerm_application_insights.apinsights.instrumentation_key

    scm_use_main_ip_restriction             = false
    ip_restriction = [
      {
        ip_address = null
        name = null
        action = "Allow"
        virtual_network_subnet_id = azurerm_subnet.asubnet["vnet-${var.project_name}-frontend-${var.env_name}"].id
        priority = "400"
        service_tag = null
        headers = null
      }
    ]
  }

  lifecycle {
    ignore_changes = [
      app_settings
    ]
  }
}