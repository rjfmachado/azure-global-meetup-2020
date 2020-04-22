variable "dockercontainer" {
  type    = string
  default = "jelledruyts/inspectorgadget"
}

resource "random_pet" "appsvcplan" {
  length    = 2
  prefix    = "appsvcplan"
  separator = "-"
}

resource "random_pet" "appsvc" {
  length    = 2
  prefix    = "appsvc"
  separator = "-"
}

resource "azurerm_app_service_plan" "appsvcplan" {
  name                = random_pet.appsvcplan.id
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "appsvc" {
  name                = random_pet.appsvc.id
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.appsvcplan.id

  https_only = true

  site_config {
    linux_fx_version = "DOCKER|${var.dockercontainer}"
    always_on        = true
  }

  lifecycle {
    ignore_changes = [
      site_config.0.dotnet_framework_version,
      site_config.0.scm_type,
      #      site_config.0.virtual_network_name,
      site_config.0.linux_fx_version,
      site_config.0.always_on,
    ]
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=${azurerm_sql_server.sql.fully_qualified_domain_name}; Initial Catalog=db-${random_pet.sql.id}; User Id=${var.sqladmin} ; password=${random_password.sqlpassword.result};"
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "appsvcvnetconnection" {
  app_service_id = azurerm_app_service.appsvc.id
  subnet_id      = azurerm_subnet.appsvc.id
}

output "app_service_default_hostname" {
  value = "https://${azurerm_app_service.appsvc.default_site_hostname}"
}
