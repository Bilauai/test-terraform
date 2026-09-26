resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.rg_name}-log-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.test_rg.name
  tags                = var.tags
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
resource "azurerm_monitor_data_collection_rule" "dcr_vmss" {
  name                = "${var.rg_name}-dcr-vmss-${var.environment}"
  resource_group_name = azurerm_resource_group.test_rg.name
  location            = var.location
  kind                = "Linux"

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.law.id
      name                  = "law"
    }
  }

  data_sources {
    syslog {
      name = "linux-syslog"

      facility_names = [
        "auth",
        "authpriv",
        "daemon",
        "syslog",
        "user"
      ]

      log_levels = [
        "Info",
        "Notice",
        "Warning",
        "Error",
        "Critical",
        "Alert",
        "Emergency"
      ]

      streams = [
        "Microsoft-Syslog"
      ]
    }
  }

  data_flow {
    streams = [
      "Microsoft-Syslog"
    ]

    destinations = [
      "law"
    ]
  }

  tags = var.tags
}
resource "azurerm_monitor_data_collection_rule_association" "data_vmss" {
  name                    = "${var.rg_name}-data-vmss-${var.environment}"
  target_resource_id      = azurerm_linux_virtual_machine_scale_set.vmss.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr_vmss.id
}

resource "azurerm_monitor_autoscale_setting" "auto_vmss" {
  name                = "autoscale-${var.environment}"
  resource_group_name = azurerm_resource_group.test_rg.name
  location            = var.location

  target_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id

  profile {
    name = "default"

    capacity {
      default = var.vmss.capacity["default"]
      minimum = var.vmss.capacity["minimum"]
      maximum = var.vmss.capacity["maximum"]
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
        metric_namespace   = "Microsoft.Compute/virtualMachineScaleSets"
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
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT10M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
        metric_namespace   = "Microsoft.Compute/virtualMachineScaleSets"
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT10M"
      }
    }
  }

  tags = var.tags
}