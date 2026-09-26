locals {
  enable_bastion = var.environment == "prod"

  subnets = {
    for key, subnet in var.network.subnets :
    key => subnet
    if key != "bastion" || local.enable_bastion
  }

  public_ips = merge(
    {
      lb = {
        name = "${var.rg_name}-pip-lb-${var.environment}"
      }
    },
    local.enable_bastion ? {
      bastion = {
        name = "${var.rg_name}-pip-bastion-${var.environment}"
      }
    } : {}
  )
}