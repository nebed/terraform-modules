locals {
  prefix = var.env.prefix
}

resource "azurerm_virtual_network" "main" {
  name                = "${local.prefix}-vnet"
  location            = var.env.location
  resource_group_name = var.env.resource_group
  address_space       = [var.network_address_space]

  tags = var.env.tags
}

## Create VNET peering from k8s  to central infra vnet to enable access to shared services and VPN
data "azurerm_virtual_network" "central" {
  name                = var.central_vnet.name
  resource_group_name = var.central_vnet.resource_group
}

data "azurerm_virtual_network" "infra_vnet" {
  name                = var.infra_vnet.name
  resource_group_name = var.infra_vnet.resource_group
}

resource "azurerm_virtual_network_peering" "this-to-central" {
  name                      = "${azurerm_virtual_network.main.name}-to-${var.central_vnet.name}-peering"
  resource_group_name       = var.env.resource_group
  virtual_network_name      = azurerm_virtual_network.main.name
  remote_virtual_network_id = data.azurerm_virtual_network.central.id
  use_remote_gateways       = var.use_remote_gateways
  allow_forwarded_traffic   = var.allow_forwarded_traffic
}

resource "azurerm_virtual_network_peering" "central-to-this" {
  name                      = "${var.central_vnet.name}-to-${azurerm_virtual_network.main.name}-peering"
  resource_group_name       = data.azurerm_virtual_network.central.resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.central.name
  remote_virtual_network_id = azurerm_virtual_network.main.id
  allow_gateway_transit     = var.allow_gateway_transit
}


resource "azurerm_virtual_network_peering" "this-to-central-infra" {
  name                      = "${azurerm_virtual_network.main.name}-to-${var.infra_vnet.name}-peering"
  resource_group_name       = var.env.resource_group
  virtual_network_name      = azurerm_virtual_network.main.name
  remote_virtual_network_id = data.azurerm_virtual_network.infra_vnet.id
}

resource "azurerm_virtual_network_peering" "central-infra-to-this" {
  name                      = "${var.infra_vnet.name}-to-${azurerm_virtual_network.main.name}-peering"
  resource_group_name       = data.azurerm_virtual_network.infra_vnet.resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.infra_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.main.id
}
