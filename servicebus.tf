resource "azurerm_servicebus_namespace" "asnamespace" {
  name                 = "sb-${var.project_name}-platform-${var.env_name}"
  resource_group_name  = azurerm_resource_group.rg["platform"].name
  location             = azurerm_resource_group.rg["platform"].location
  sku                  = "Standard"
  capacity             = 0

  tags = {
    Environment = var.env_name,
  }
}

resource "azurerm_servicebus_topic" "astopic" {
  for_each     = toset([for st in local.map_sb_topics: st.sbt_name])
  name         = each.key
  namespace_id = azurerm_servicebus_namespace.asnamespace.id

  default_message_ttl = "P4D"
  enable_partitioning = false
}

resource "azurerm_servicebus_subscription" "assubscription" {
  for_each     = {
    for sb in local.map_sb_topics: "${sb.sb_name}-${sb.sbt_name}-${sb.sbt_sub}" => sb
    }
  name               = each.value.sbt_sub
  topic_id           = azurerm_servicebus_topic.astopic[each.value.sbt_name].id

  max_delivery_count  = 3
  default_message_ttl = "P4D"
  lock_duration       = "P0DT0H2M0S"
  auto_delete_on_idle = "P4D"
}

//Shared access policy

resource "azurerm_servicebus_namespace_authorization_rule" "sasservice" {
  for_each     =  local.set_sb_sas
  name         = "${each.key}"
  namespace_id = azurerm_servicebus_namespace.asnamespace.id

  listen = true
  send   = true
  manage = true
}