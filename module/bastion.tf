resource "azurerm_bastion_host" "bastion" {
  count = local.enable_bastion ? 1 : 0

  name                = "${var.rg_name}-bas-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.test_rg.name
  sku                 = var.bastion_sku

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = azurerm_subnet.subnet["bastion"].id
    public_ip_address_id = azurerm_public_ip.public_ip["bastion"].id
  }

  tags = var.tags
}