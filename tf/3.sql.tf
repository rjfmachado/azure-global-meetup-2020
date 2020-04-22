variable "sqladmin" {
  type    = string
  default = "sqladmin"
}

resource "random_pet" "sql" {
  length    = 2
  prefix    = "sql"
  separator = "-"
}

resource "random_password" "sqlpassword" {
  length           = 24
  special          = true
  lower            = true
  min_lower        = 1
  upper            = true
  min_upper        = 1
  number           = true
  override_special = "_%@"
}

resource "azurerm_sql_server" "sql" {
  name                         = random_pet.sql.id
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sqladmin
  administrator_login_password = random_password.sqlpassword.result
}

resource "azurerm_sql_database" "sqldb" {
  name                = "db-${random_pet.sql.id}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  server_name         = azurerm_sql_server.sql.name
}

output "sqlfqdn" {
  value = azurerm_sql_server.sql.fully_qualified_domain_name
}

output "sqladmin" {
  value = azurerm_sql_server.sql.administrator_login
}
