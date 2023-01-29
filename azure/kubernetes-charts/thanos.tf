##Install Thanos Helm Chart
resource "helm_release" "thanos" {
  count            = var.enable_thanos ? 1 : 0
  name             = "thanos"
  namespace        = var.monitoring_namespace
  chart            = "thanos"
  repository       = "https://charts.bitnami.com/bitnami"
  version          = var.thanos_chart_version
  create_namespace = true
  values = [
    templatefile("${path.module}/templates/thanos/values.yaml", {
      storage_account_name = var.storage_account_name
      thanosstores         = var.thanosstores
      load_balancer_subnet = var.internal_lb_subnet
      cluster_name         = var.dns_prefix
    }),
  ]
}

resource "azurerm_private_dns_cname_record" "thanos_dns_record" {
  count               = var.enable_thanos ? 1 : 0
  name                = "thanos"
  zone_name           = var.internal_ingress.internal_dns_zone
  resource_group_name = var.internal_ingress.internal_dns_zone_rg
  record              = azurerm_private_dns_a_record.internal_ingress_lb_dns_record[0].fqdn
  ttl                 = 3600
  tags                = var.tags
}

resource "azurerm_private_dns_cname_record" "thanos_query_dns_record" {
  count               = var.enable_thanos ? 1 : 0
  name                = "thanos-query"
  zone_name           = var.internal_ingress.internal_dns_zone
  resource_group_name = var.internal_ingress.internal_dns_zone_rg
  record              = azurerm_private_dns_a_record.internal_ingress_lb_dns_record[0].fqdn
  ttl                 = 3600
  tags                = var.tags
}
