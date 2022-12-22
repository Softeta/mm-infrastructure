locals {
  map_rg_app_name = merge([
    for map_rg_name in var.sqs_data: {
      for map_app_name in map_rg_name.app_name: 
      "${map_rg_name.rg_name}-${map_rg_name.app_plan}-${map_app_name}" => {
        "rg_name"   = map_rg_name.rg_name
        "app_name"  = map_app_name
        "plan_name" = map_rg_name.app_plan
      }
    }
    if contains(keys(map_rg_name), "app_name")
  ]...)

  map_rg_container_app_name = merge([
    for map_rg_name in var.sqs_data: {
    for map_app_container_name in map_rg_name.app_container_name:
    "${map_rg_name.rg_name}-${map_rg_name.app_plan}-${map_app_container_name}" => {
        "rg_name"   = map_rg_name.rg_name
        "app_container_name"  = map_app_container_name
        "plan_name" = map_rg_name.app_plan
        "container_image" = map_rg_name.container_image
    }
    }
    if contains(keys(map_rg_name), "app_container_name")
  ]...)
}

locals {
  serviceplan = flatten([
    for newobject in var.sqs_data:
        contains([], newobject.app_plan) == false ? concat([], [newobject.app_plan]) : []
    if  contains(keys(newobject), "app_name") 
    ])
}

# locals {
#   funcserviceplan = flatten([
#     for newobject in var.sqs_data: 
#         contains([], newobject.func_app_plan) == false ? concat([], [newobject.func_app_plan]) : []
#     if  contains(keys(newobject), "fun_app_name") 
#     ])
# }

locals {
  funcserviceplan = merge({
    for map_sb in var.sqs_data: 
    "${map_sb.own_app_plan}" => {
          "plan_name" = map_sb.own_app_plan
          "rg_name"  = map_sb.rg_name
    }    
    if contains(keys(map_sb), "fun_app_name") && contains(keys(map_sb), "own_app_plan")
  })
}

locals {
  skuserviceplan = merge({
    for map_sb in var.sqs_data: 
    "${map_sb.app_plan}" => {
          "plan_name" = map_sb.app_plan
          "sku_name"  = map_sb.sku_plan[var.env_name]
          "env_name"  = var.env_name
    }    
    if contains(keys(map_sb), "sku_plan")
  })
}

locals {
  sqlskuplans = merge({
    for map_sb in var.sqs_data: 
    "${map_sb.sql_name}" => {
          "sku_name"  = map_sb.sql_sku[var.env_name]
          "env_name"  = var.env_name
    }    
    if contains(keys(map_sb), "sql_sku")
  })
}

/*
locals {
  serviceplanlist = [
    for serviceplan in var.sqs_data: {
      serviceplanlist = concat(local.serviceplanlist, [serviceplan.rg_name])
    }
    if contains(local.serviceplanlist, serviceplan.rg_name) == false
  ]
}*/

locals {
  map_st_stc_type = merge([
    for map_st_name in var.sqs_data: {
      for stc_name, stc_type in map_st_name.storage:
        "${map_st_name.rg_name}-${stc_name}-${stc_type}" => {
          "st_name"   = map_st_name.rg_name
          "stc_name"  = stc_name
          "stc_type"  = stc_type
        }
    }
    if contains(keys(map_st_name), "storage")
  ]...)
}


locals {
  set_st_name = toset([
    for st_name in var.sqs_data: 
    st_name.rg_name if contains(keys(st_name), "storage")
  ])
}

locals {
  st_subnet = merge({
    for st_net in var.sqs_data: 
      "${st_net.rg_name}-${st_net.subnet}" => {
        "storage"  = st_net.rg_name
        "subnet"   = st_net.subnet
    }
    if contains(keys(st_net), "subnet") && contains(keys(st_net), "storage")
})
}

locals {
  map_sql_name = merge({
    for map_sql_name in var.sqs_data:
    "${map_sql_name.sql_name}" => {
          "sql_name"   = map_sql_name.sql_name
        }

    if contains(keys(map_sql_name), "sql_name") 
  })
}

locals {
  map_psql_name = merge({
  for map_psql_name in var.sqs_data:
  "${map_psql_name.psql_name}" => {
    "psql_name"   = map_psql_name.psql_name
  }

  if contains(keys(map_psql_name), "psql_name")
  })
}


locals {
  map_sb_topics = flatten([
    for map_sb in var.sqs_data:[
      for sb_topic, sbt_sub_list in map_sb.sb_topic_sub: [
        for sbt_sub in sbt_sub_list: {
//        "${map_sb.rg_name}-${sb_topic}-${sbt_sub}" => {
          "sb_name"   = map_sb.rg_name
          "sbt_name"  = sb_topic
          "sbt_sub"   = sbt_sub
         }
      ]
    ]
    if contains(keys(map_sb), "sb_topic_sub")
  ])
}

locals {
  set_sb_sas = toset([
    for sas in var.sqs_data: 
    sas.sb_sas if contains(keys(sas), "sb_sas")
  ])
}

locals {
  map_srch_name = merge({
    for map_srch_name in var.sqs_data:
    "${map_srch_name.srch_name}" => {
          "srch_name"   = map_srch_name.srch_name
        }

    if contains(keys(map_srch_name), "srch_name")
  })
}

locals {
  map_plan_func_name = merge([
    for map_rg_name in var.sqs_data: {
      for map_app_name in map_rg_name.fun_app_name: 
      "${map_rg_name.rg_name}-${map_app_name}" => {
        "rg_name"   = map_rg_name.rg_name
        "func_name" = map_app_name,
        "plan_name" = map_rg_name.func_app_plan
      }
    }
    if contains(keys(map_rg_name), "fun_app_name") && contains(keys(map_rg_name), "func_app_plan")
  ]...)
}

locals {
  map_time_trigger_plan_func_name = merge([
    for map_rg_name in var.sqs_data: {
      for map_app_name in map_rg_name.fun_app_name: 
      "${map_rg_name.rg_name}-${map_app_name}" => {
        "rg_name"   = map_rg_name.rg_name
        "func_name" = map_app_name,
        "plan_name" = map_rg_name.time_trigger.plan_name
      }
    }
    if contains(keys(map_rg_name), "time_trigger") && contains(keys(map_rg_name), "fun_app_name")
  ]...)
}

locals {
  map_plan_with_own_func_name = merge([
    for map_rg_name in var.sqs_data: {
      for map_app_name in map_rg_name.fun_app_name: 
      "${map_rg_name.rg_name}-${map_app_name}" => {
        "rg_name"   = map_rg_name.rg_name
        "func_name" = map_app_name,
        "plan_name" = map_rg_name.own_app_plan
      }
    }
    if contains(keys(map_rg_name), "fun_app_name") && contains(keys(map_rg_name), "own_app_plan")
  ]...)
}


# improve to support subnet branch
locals {
  network_block_legacy = [
    for vnet_group in var.subnet_names: {
            "name"   = "vnet-${var.project_name}-${vnet_group}-${var.env_name}"
            new_bits = 10

    }
  ]
}

# improve to support subnet branch
locals {
  network_block = [
    for vnet_group in var.sqs_data: {
            "name"   = "vnet-${var.project_name}-${vnet_group.rg_name}-${var.env_name}"
            new_bits = 10

    }
    if contains(keys(vnet_group), "rg_name")
  ]
}

# container registry names
locals {
  map_cr_name = merge({
  for map_cr_name in var.sqs_data:
  "${map_cr_name.cr_name}" => {
    "cr_name"   = map_cr_name.cr_name
  }

  if contains(keys(map_cr_name), "cr_name")
  })
}