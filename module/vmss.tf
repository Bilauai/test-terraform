resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                            = "${var.rg_name}-vmss-${var.environment}"
  resource_group_name             = azurerm_resource_group.test_rg.name
  location                        = var.location
  sku                             = var.vmss.sku
  instances                       = var.vmss.capacity.default
  tags                            = var.tags
  admin_username                  = "azureadmin"
  disable_password_authentication = true
  upgrade_mode                    = var.vmss.upgrade_mode
  zone_balance                    = length(var.vmss.zones) > 1
  zones                           = var.vmss.zones
  health_probe_id                 = azurerm_lb_probe.lb_probe.id
  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = "azureadmin"
    public_key = var.ssh_public_key
  }

  automatic_instance_repair {
    enabled      = true
    action       = "Replace"
    grace_period = "PT10M"
  }

  automatic_os_upgrade_policy {
    automatic_os_upgrade_enabled = true
    automatic_rollback_enabled   = true
  }

  source_image_reference {
    publisher = var.vmss.image.publisher
    offer     = var.vmss.image.offer
    sku       = var.vmss.image.sku
    version   = var.vmss.image.version
  }

  os_disk {
    storage_account_type = var.vmss.os_disk.storage_account_type
    caching              = var.vmss.os_disk.caching
  }

  rolling_upgrade_policy {
    max_batch_instance_percent              = var.vmss.rolling_upgrade.max_batch_instance_percent
    max_unhealthy_instance_percent          = var.vmss.rolling_upgrade.max_unhealthy_instance_percent
    max_unhealthy_upgraded_instance_percent = var.vmss.rolling_upgrade.max_unhealthy_upgraded_instance_percent
    pause_time_between_batches              = var.vmss.rolling_upgrade.pause_time_between_batches
  }

  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.subnet["vm"].id

      load_balancer_backend_address_pool_ids = [
        azurerm_lb_backend_address_pool.lb_pool.id
      ]
    }
  }

  custom_data = base64encode(
    file("${path.module}/cloud-init.yaml")
  )

  lifecycle {
    ignore_changes = [
      instances
    ]
  }
}

resource "azurerm_virtual_machine_scale_set_extension" "entra_ssh" {
  name                         = "AADSSHLoginForLinux"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.vmss.id
  publisher                    = "Microsoft.Azure.ActiveDirectory"
  type                         = "AADSSHLoginForLinux"
  type_handler_version         = "1.0"
  auto_upgrade_minor_version   = true
  depends_on = [
    azurerm_virtual_machine_scale_set_extension.azure_monitor_agent
  ]

}

resource "azurerm_virtual_machine_scale_set_extension" "azure_monitor_agent" {
  name                         = "AzureMonitorLinuxAgent"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.vmss.id
  publisher                    = "Microsoft.Azure.Monitor"
  type                         = "AzureMonitorLinuxAgent"
  type_handler_version         = "1.0"
  auto_upgrade_minor_version   = true
  automatic_upgrade_enabled    = true
  depends_on = [
    azurerm_linux_virtual_machine_scale_set.vmss
  ]

}