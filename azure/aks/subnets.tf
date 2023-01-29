resource "azurerm_subnet" "nodes" {
  name                 = "${local.prefix}-nodes"
  resource_group_name  = var.env.resource_group
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.nodes_subnet]
  service_endpoints    = var.nodes_subnet_service_endpoints

  enforce_private_link_endpoint_network_policies = var.enforce_private_link_endpoint_network_policies

  lifecycle {
    ignore_changes = [service_endpoints]
  }
}

resource "azurerm_network_security_rule" "internet_80_443" {
  name                        = "AllowInternet_80_443"
  description                 = "Allow Internet traffic to public Ingress"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["80","443"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.env.resource_group
  network_security_group_name = azurerm_network_security_group.nodes.name
}

resource "azurerm_network_security_group" "nodes" {
  name                = "${local.prefix}-nodes"
  resource_group_name = var.env.resource_group
  location            = var.env.location
  tags                = var.env.tags
}

resource "azurerm_subnet_network_security_group_association" "nodes" {
  subnet_id                 = azurerm_subnet.nodes.id
  network_security_group_id = azurerm_network_security_group.nodes.id
}

resource "azurerm_subnet" "internal" {
  name                 = "${local.prefix}-internal"
  resource_group_name  = var.env.resource_group
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.internal_subnet]
  service_endpoints    = var.internal_subnet_service_endpoints

  enforce_private_link_endpoint_network_policies = var.enforce_private_link_endpoint_network_policies

  lifecycle {
    ignore_changes = [service_endpoints]
  }
}

resource "azurerm_network_security_group" "internal" {
  name                = "${local.prefix}-internal"
  resource_group_name = var.env.resource_group
  location            = var.env.location
  tags                = var.env.tags
}

resource "azurerm_subnet_network_security_group_association" "internal" {
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = azurerm_network_security_group.internal.id
}
