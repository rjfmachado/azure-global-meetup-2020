variable "adminuser" {
  type    = string
  default = "ricardma"
}

resource "random_pet" "vm" {
  length    = 2
  prefix    = "vm"
  separator = "-"
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-${random_pet.vm.id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig-${random_pet.vm.id}"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

resource "azurerm_public_ip" "publicip" {
  name                = "pip-${random_pet.vm.id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  domain_name_label   = random_pet.vm.id
}

variable "cloudconfig_file" {
  description = "The location of the cloud init configuration file."
  default     = "base.tpl"
}

data "template_file" "cloudconfig" {
  template = file(var.cloudconfig_file)
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.cloudconfig.rendered
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = random_pet.vm.id
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = var.adminuser
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  #custom_data = data.template_cloudinit_config.config.rendered

  admin_ssh_key {
    username   = var.adminuser
    public_key = file("~/.ssh/id_rsa.pub")
  }

  disable_password_authentication = true

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

output "vmfqnd" {
  value = azurerm_public_ip.publicip.fqdn
}

output "vmpublicip" {
  value = azurerm_linux_virtual_machine.vm.public_ip_address
}

output "vmadmin" {
  value = var.adminuser
}
