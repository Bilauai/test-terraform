rg_name     = "trial"
environment = "dev"
location    = "eastus2"

network = {
  address_space = ["10.10.0.0/16"]

  subnets = {
    vm = {
      name   = "snet-vm"
      prefix = "10.10.1.0/24"
    }
  }
}

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
  Project     = "VMSS"
  Application = "Test"
}

lb = {
  protocol      = "Tcp"
  frontend_port = 80
  backend_port  = 80
  sku           = "Standard"

  health_probe = {
    protocol            = "Http"
    port                = 80
    request_path        = "/health"
    interval_in_seconds = 5
    number_of_probes    = 2
  }
}

vmss = {
  sku            = "Standard_D2als_v7"
  zones          = ["1"]
  admin_username = "azureadmin"
  upgrade_mode   = "Rolling"

  capacity = {
    default = 2
    minimum = 2
    maximum = 4
  }

  image = {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  os_disk = {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  rolling_upgrade = {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 20
    pause_time_between_batches              = "PT5M"
  }
}

nsg_rules = {
  AllowHTTP = {
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}