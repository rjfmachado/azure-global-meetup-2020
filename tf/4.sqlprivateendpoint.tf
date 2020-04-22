resource "azurerm_private_endpoint" "sqlprivateendpoint" {
  name                = "pe-${random_pet.sql.id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.privateendpoint.id

  private_service_connection {
    name                           = "pe-connection-${random_pet.sql.id}"
    private_connection_resource_id = azurerm_sql_server.sql.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }
}

resource "azurerm_private_dns_a_record" "sqldnsrecord" {
  name                = random_pet.sql.id
  zone_name           = azurerm_private_dns_zone.sqlprivatednszone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = ["${azurerm_private_endpoint.sqlprivateendpoint.private_service_connection[0].private_ip_address}"]
}

output "sqlprivateip" {
  value = azurerm_private_endpoint.sqlprivateendpoint.private_service_connection[0].private_ip_address
}
