resource "azurerm_resource_group" "rg" {
  name = var.resource_group_name
  location = var.location
}

resource "azurerm_postgresql_server" "foxpsql" {
  name                = "devops-tools22"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  sku_name = "B_Gen5_2"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = "foxutech"
  administrator_login_password = "myson@rTempP@$$"
  version                      = "11"
  ssl_enforcement_enabled      = false
}

resource "azurerm_postgresql_database" "foxpsql" {
  name                = "sonarqube"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.foxpsql.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_configuration" "foxpsql" {
  name                = "backslash_quote"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.foxpsql.name
  value               = "on"
}
