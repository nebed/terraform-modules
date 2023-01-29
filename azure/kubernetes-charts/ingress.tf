#---------------------------------------------------
# Ingress controllers
#---------------------------------------------------
locals {
  certificates = {
    internal = "${var.cert_manager.namespace}/${var.cert_manager.ingress_certs.internal}"
    public   = "${var.cert_manager.namespace}/${var.cert_manager.ingress_certs.public}"
  }
}

resource "helm_release" "nginx_ingress_internal" {
  count = var.enable_internal_ingress ? 1 : 0

  name             = var.internal_ingress.name
  namespace        = var.internal_ingress.namespace
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.internal_ingress.chart_version
  create_namespace = true

  # https://github.com/helm/helm/issues/7811
  atomic          = true
  cleanup_on_fail = true

  values = [
    templatefile("${path.module}/templates/ingress-nginx/common.values.yaml", {
      class_resource_name          = var.internal_ingress.class_name
      controller_value             = var.internal_ingress.controller_value
      load_balancer_ip             = var.internal_lb_ip
      load_balancer_resource_group = var.internal_lb_rg
      default_tls_certificate      = local.certificates.internal
    }),
    templatefile("${path.module}/templates/ingress-nginx/internal.values.yaml", {
      load_balancer_subnet = var.internal_lb_subnet
    }),
  ]
}

locals {
  dns_record_enabled = var.enable_internal_ingress && var.internal_ingress_lb_dns_record != ""
}
resource "azurerm_private_dns_a_record" "internal_ingress_lb_dns_record" {
  count               = local.dns_record_enabled ? 1 : 0
  name                = var.internal_ingress_lb_dns_record
  zone_name           = var.internal_ingress.internal_dns_zone
  resource_group_name = var.internal_ingress.internal_dns_zone_rg
  records             = [var.internal_lb_ip]
  ttl                 = 3600
  tags                = var.tags
}

resource "helm_release" "nginx_ingress_public" {
  count = var.enable_public_ingress ? 1 : 0

  name             = var.public_ingress.name
  namespace        = var.public_ingress.namespace
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.public_ingress.chart_version
  create_namespace = true

  # https://github.com/helm/helm/issues/7811
  atomic          = true
  cleanup_on_fail = true

  values = [
    templatefile("${path.module}/templates/ingress-nginx/common.values.yaml", {
      class_resource_name          = var.public_ingress.class_name
      controller_value             = var.public_ingress.controller_value
      load_balancer_ip             = var.public_lb_ip
      load_balancer_resource_group = var.public_lb_rg
      default_tls_certificate      = local.certificates.public
    })
  ]
}
