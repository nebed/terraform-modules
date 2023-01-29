data "azurerm_key_vault" "admin" {
  name                = var.admin_keyvault.name
  resource_group_name = var.admin_keyvault.rg
}

data "azurerm_key_vault_secret" "dnsmadeeasy_api_key" {
  name         = var.dnsmadeeasy.api_key_name
  key_vault_id = data.azurerm_key_vault.admin.id
}

data "azurerm_key_vault_secret" "dnsmadeeasy_secret_key" {
  name         = var.dnsmadeeasy.secret_key_name
  key_vault_id = data.azurerm_key_vault.admin.id
}

#---------------------------------------------------
# cert-manager for automated Let's Encrypt certificate management
#---------------------------------------------------
resource "helm_release" "cert_manager" {
  count = var.enable_cert_manager ? 1 : 0

  name             = var.cert_manager.name
  namespace        = var.cert_manager.namespace
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.cert_manager.chart_version
  create_namespace = true

  # https://github.com/helm/helm/issues/7811
  atomic          = true
  cleanup_on_fail = true

  values = [
    templatefile("${path.module}/templates/cert-manager/values.yaml", {
      # NOTE: Pass template parameters here
    })
  ]
}

#---------------------------------------------------
# Cluster issuer with DNS Made Easy webhook solver for DNS-01 challenge
#---------------------------------------------------
locals {
  enable_issuer = var.enable_internal_ingress || var.enable_public_ingress
}

resource "kubectl_manifest" "dnsmadeeasy_secret" {
  count = local.enable_issuer ? 1 : 0

  override_namespace = var.cert_manager.namespace
  sensitive_fields   = ["data", "stringData"]
  yaml_body = templatefile(
    "${path.module}/templates/dnsmadeeasy-webhook/manifests/secret.yaml", {
      key    = data.azurerm_key_vault_secret.dnsmadeeasy_api_key.value
      secret = data.azurerm_key_vault_secret.dnsmadeeasy_secret_key.value
  })
  depends_on = [helm_release.cert_manager]
}

resource "helm_release" "dnsmadeeasy_webhook" {
  count = local.enable_issuer ? 1 : 0

  name       = "dnsmadeeasy-webhook"
  namespace  = var.cert_manager.namespace
  repository = "https://k8s-at-home.com/charts/"
  chart      = "dnsmadeeasy-webhook"
  version    = var.dnsmadeeasy.chart_version

  # https://github.com/helm/helm/issues/7811
  atomic          = true
  cleanup_on_fail = true

  values = [
    templatefile("${path.module}/templates/dnsmadeeasy-webhook/values.yaml", {
      group_name = var.cert_manager.issuers.dnsmadeeasy.group_name
    })
  ]
  depends_on = [kubectl_manifest.dnsmadeeasy_secret]
}

resource "kubectl_manifest" "letsencrypt_dnsmadeeasy_issuer" {
  count = local.enable_issuer ? 1 : 0

  override_namespace = var.cert_manager.namespace
  yaml_body = templatefile(
    "${path.module}/templates/cert-manager/manifests/issuer.yaml", {
      name        = var.cert_manager.issuers.dnsmadeeasy.name
      server      = var.cert_manager.issuers.dnsmadeeasy.server
      email       = var.cert_manager.issuers.dnsmadeeasy.email
      secret_name = var.cert_manager.issuers.dnsmadeeasy.secret_name
      group_name  = var.cert_manager.issuers.dnsmadeeasy.group_name
  })
  depends_on = [helm_release.dnsmadeeasy_webhook]
}

#---------------------------------------------------
# Certificates
#---------------------------------------------------
locals {
  cert_templates = {
    internal = join("", [
      "${path.module}/templates/cert-manager/manifests/",
      var.enable_base_domain_cert ? "multi-domain-" : "",
      "wildcard-cert.yaml"
    ])
    public = "${path.module}/templates/cert-manager/manifests/wildcard-cert.yaml"
  }
}

resource "kubectl_manifest" "internal_myzone_cert" {
  count = var.enable_internal_ingress ? 1 : 0

  override_namespace = var.cert_manager.namespace
  yaml_body = templatefile(local.cert_templates.internal, {
    domain      = "${var.dns_prefix}.int.myzone.testsample"
    base_domain = "int.myzone.testsample"
    issuer      = var.cert_manager.issuers.dnsmadeeasy.name
    name        = var.cert_manager.ingress_certs.internal
  })

  depends_on = [kubectl_manifest.letsencrypt_dnsmadeeasy_issuer]
}

resource "kubectl_manifest" "public_myzone_cert" {
  count = var.enable_public_ingress ? 1 : 0

  override_namespace = var.cert_manager.namespace
  yaml_body = templatefile(local.cert_templates.public, {
    domain = "myzone.testsample"
    issuer = var.cert_manager.issuers.dnsmadeeasy.name
    name   = var.cert_manager.ingress_certs.public
  })

  depends_on = [kubectl_manifest.letsencrypt_dnsmadeeasy_issuer]
}
