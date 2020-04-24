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
  reserved            = false
  kind                = "Windows"

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
    always_on = true
  }

  app_settings = {
    "WEBSITE_DNS_SERVER"     = "168.63.129.16"
    "WEBSITE_VNET_ROUTE_ALL" = 1
  }

  connection_string {
    name  = "Database"
    type  = "SQLAzure"
    value = "Server=tcp:${azurerm_sql_server.sql.fully_qualified_domain_name},1433; Database=db-${random_pet.sql.id}; User ID=${var.sqladmin} ; password=${random_password.sqlpassword.result};"
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "appsvcvnetconnection" {
  app_service_id = azurerm_app_service.appsvc.id
  subnet_id      = azurerm_subnet.appsvc.id
}

output "app_service_default_hostname" {
  value = "https://${azurerm_app_service.appsvc.default_site_hostname}"
}
