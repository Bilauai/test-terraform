variable "environment" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "ssh_public_key" {
  description = "SSH public key used for VMSS access"
  type        = string
  sensitive   = true
}


variable "tags" {
  description = "Tags applied to resources"
  type        = map(string)
}

variable "bastion_sku" {
  description = "bastion sku"
  type        = string
  default     = "Basic"
}

variable "network" {
  description = "VNet and subnet configuration"

  type = object({
    address_space = list(string)

    subnets = map(object({
      name   = string
      prefix = string
    }))
  })
}

variable "lb" {
  description = "load balancer configuration"

  type = object({
    protocol      = string
    frontend_port = number
    backend_port  = number
    sku           = string

    health_probe = object({
      protocol            = string
      port                = number
      request_path        = string
      interval_in_seconds = number
      number_of_probes    = number
    })
  })
}

variable "vmss" {
  description = "VM Scale Set configuration"

  type = object({
    sku          = string
    zones        = list(string)
    upgrade_mode = string

    capacity = object({
      default = number
      minimum = number
      maximum = number
    })

    image = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })

    os_disk = object({
      storage_account_type = string
      caching              = string
    })

    rolling_upgrade = object({
      max_batch_instance_percent              = number
      max_unhealthy_instance_percent          = number
      max_unhealthy_upgraded_instance_percent = number
      pause_time_between_batches              = string
    })
  })
}

variable "nsg_rules" {
  type = map(object({
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
}