data "azurerm_private_dns_zone" "k8s" {
  name                = "privatelink.${var.env.location}.azmk8s.io"
  resource_group_name = var.dns_rg
}

## Vnet link to central private ingress dns zone
data "azurerm_private_dns_zone" "ingress" {
  name                = var.ingress_dns.name
  resource_group_name = var.ingress_dns.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "ingress" {
  name                  = "${azurerm_virtual_network.main.name}-dns-link"
  resource_group_name   = data.azurerm_private_dns_zone.ingress.resource_group_name
  private_dns_zone_name = data.azurerm_private_dns_zone.ingress.name
  virtual_network_id    = azurerm_virtual_network.main.id
  tags                  = var.env.tags
}

## Vnet link to central private postgres dns zone
data "azurerm_private_dns_zone" "postgres" {
  name                = var.postgres_dns.name
  resource_group_name = var.postgres_dns.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "${azurerm_virtual_network.main.name}-dns-link"
  resource_group_name   = data.azurerm_private_dns_zone.postgres.resource_group_name
  private_dns_zone_name = data.azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.main.id
  tags                  = var.env.tags
}


## Vnet link to central private mssql dns zone
data "azurerm_private_dns_zone" "mssql" {
  name                = var.mssql_dns.name
  resource_group_name = var.mssql_dns.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "mssql" {
  name                  = "${azurerm_virtual_network.main.name}-dns-link"
  resource_group_name   = data.azurerm_private_dns_zone.mssql.resource_group_name
  private_dns_zone_name = data.azurerm_private_dns_zone.mssql.name
  virtual_network_id    = azurerm_virtual_network.main.id
  tags                  = var.env.tags
}


## Vnet link to central private azure websites dns zone
data "azurerm_private_dns_zone" "azurewebsites" {
  name                = var.azurewebsites_dns.name
  resource_group_name = var.azurewebsites_dns.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "azurewebsites" {
  name                  = "${azurerm_virtual_network.main.name}-dns-link"
  resource_group_name   = data.azurerm_private_dns_zone.azurewebsites.resource_group_name
  private_dns_zone_name = data.azurerm_private_dns_zone.azurewebsites.name
  virtual_network_id    = azurerm_virtual_network.main.id
  tags                  = var.env.tags
}

## Vnet link to central private azure redis dns zone
data "azurerm_private_dns_zone" "redis" {
  name                = var.redis_dns.name
  resource_group_name = var.redis_dns.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis" {
  name                  = "${azurerm_virtual_network.main.name}-dns-link"
  resource_group_name   = data.azurerm_private_dns_zone.redis.resource_group_name
  private_dns_zone_name = data.azurerm_private_dns_zone.redis.name
  virtual_network_id    = azurerm_virtual_network.main.id
  tags                  = var.env.tags
}




