output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "DBServerName" {
  value = azurerm_postgresql_server.foxpsql.name
}
