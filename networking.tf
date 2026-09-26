resource "azurerm_virtual_network" "vnet" {
  name                = "${var.rg_name}-vnet-${var.environment}"
  address_space       = var.network.address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.test_rg.name
  depends_on = [
    azurerm_resource_group.test_rg
  ]
}

resource "azurerm_public_ip" "public_ip" {
  for_each = local.public_ips

  name                = each.value.name
  location            = var.location
  resource_group_name = azurerm_resource_group.test_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_subnet" "subnet" {
  for_each = local.subnets

  name                 = each.value.name
  resource_group_name  = azurerm_resource_group.test_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = [
    each.value.prefix
  ]
}

resource "azurerm_network_security_group" "nsg_vmss" {
  name                = "${var.rg_name}-nsg-vmss-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.test_rg.name
  depends_on = [
    azurerm_resource_group.test_rg
  ]
  # Application traffic
  dynamic "security_rule" {
    for_each = var.nsg_rules

    content {
      name                       = security_rule.key
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "vmss" {
  subnet_id                 = azurerm_subnet.subnet["vm"].id
  network_security_group_id = azurerm_network_security_group.nsg_vmss.id
  depends_on = [
    azurerm_subnet.subnet["vm"],
    azurerm_network_security_group.nsg_vmss
  ]
}