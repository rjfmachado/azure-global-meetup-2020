resource "random_pet" "vnetname" {
  length    = 2
  prefix    = "vnet"
  separator = "-"
}

resource "azurerm_virtual_network" "vnet" {
  name                = random_pet.vnetname.id
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "appsvc" {
  name                 = "appsvc"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.0.0.0/24"

  delegation {
    name = "delegationappsvc"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ]
    }
  }
}

resource "azurerm_subnet" "privateendpoint" {
  name                                           = "privateendpoint"
  resource_group_name                            = azurerm_resource_group.rg.name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefix                                 = "10.0.1.0/24"
  enforce_private_link_endpoint_network_policies = true
  #
}

resource "azurerm_subnet" "vm" {
  name                 = "vm"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.0.2.0/24"
}

output "vnetname" {
  value = azurerm_virtual_network.vnet.name
}
