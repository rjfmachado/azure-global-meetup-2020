terraform {
  required_version = ">= 0.12.24"
}

provider "azurerm" {
  version = "~> 2.6"

  features {
    virtual_machine {
      delete_os_disk_on_deletion = true
    }
  }
}

provider "random" {
  version = "~> 2.2"
}

data "azurerm_client_config" "current" {
}

resource "random_pet" "labname" {
  length    = 2
  prefix    = "rgGlobalMeetup2020"
  separator = "-"
}

resource "azurerm_resource_group" "rg" {
  name     = random_pet.labname.id
  location = "southcentralus"
}

output "rgname" {
  value = azurerm_resource_group.rg.name
}
