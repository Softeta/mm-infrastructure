resource "azurerm_monitor_autoscale_setting" "default" {
  for_each            = ( var.env_name == "dev" ?
                          {} : (
                            var.env_name == "sand" ? 
                              {} :
                              azurerm_service_plan.asplan
                            )
                        )
  name                = "${each.value.name}-autoscale"
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  target_resource_id  = each.value.id

  tags = {
    Environment = var.env_name,
  }

  profile {
    name = "defaultProfile"

    capacity {
      default = 2
      minimum = var.env_name == "prod" ? 2 : 1
      maximum = 5
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = each.value.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT10M"
        time_aggregation   = "Maximum"
        operator           = "GreaterThan"
        threshold          = 75
        metric_namespace   = "microsoft.web/serverfarms"
        divide_by_instance_count = false
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = each.value.id
        metric_namespace   = "microsoft.web/serverfarms"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT10M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 55
        divide_by_instance_count = false
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = false
      send_to_subscription_co_administrator = false
      custom_emails                         = []
    }
  }
}