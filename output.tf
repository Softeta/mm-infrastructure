output "resource_group_name" {
    value = azurerm_resource_group.rg
}

output "map_rg_app_name" {
  value = local.map_rg_app_name
}

output "map_st_stc_type" {
  value = local.map_st_stc_type
}

output "map_sql_name" {
  value = local.map_sql_name
}