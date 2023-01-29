resource "azurerm_public_ip" "this" {
  count = var.enable_public_ingress ? 1 : 0

  name                = "${local.prefix}-public-ingress-ip"
  resource_group_name = var.env.resource_group
  location            = var.env.location
  allocation_method   = "Static"
  domain_name_label   = "${local.prefix}-public"
  sku                 = "Standard"
  tags                = var.env.tags
}
