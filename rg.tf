resource "azurerm_resource_group" "test_rg" {
  name     = "${var.rg_name}-${var.environment}"
  location = var.location
}
