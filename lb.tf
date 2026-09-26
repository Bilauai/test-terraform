resource "azurerm_lb" "lb" {
  name                = "${var.rg_name}-lb-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.test_rg.name
  sku                 = var.lb.sku

  frontend_ip_configuration {
    name                 = "frontend"
    public_ip_address_id = azurerm_public_ip.public_ip["lb"].id
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "lb_pool" {
  name            = "vmss-backend"
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "lb_probe" {
  name            = "lb-health"
  loadbalancer_id = azurerm_lb.lb.id

  protocol            = var.lb.health_probe.protocol
  port                = var.lb.health_probe.port
  request_path        = var.lb.health_probe.request_path
  interval_in_seconds = var.lb.health_probe.interval_in_seconds
  number_of_probes    = var.lb.health_probe.number_of_probes
}

resource "azurerm_lb_rule" "lb_rule" {
  name                           = "lb-rule"
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = var.lb.protocol
  frontend_port                  = var.lb.frontend_port
  backend_port                   = var.lb.backend_port
  frontend_ip_configuration_name = "frontend"

  backend_address_pool_ids = [
    azurerm_lb_backend_address_pool.lb_pool.id
  ]

  probe_id = azurerm_lb_probe.lb_probe.id
}