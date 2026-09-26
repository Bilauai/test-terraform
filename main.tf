module "scotia_vm" {
  source         = "./modules/vm"
  rg_name        = var.rg_name
  environment    = var.environment
  location       = var.location
  ssh_public_key = var.ssh_public_key
  bastion_sku    = var.bastion_sku
  tags           = var.tags
  lb             = var.lb
  vmss           = var.vmss
  network        = var.network
  nsg_rules      = var.nsg_rules
}
