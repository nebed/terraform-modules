locals {
  thanos_secret = templatefile("${path.module}/templates/kube-prometheus-stack/manifests/thanos.yaml", {
    storage_account_name = var.storage_account_name
  })
}

resource "kubectl_manifest" "monitoring" {
  count = var.enable_prometheus ? 1 : 0
  yaml_body = templatefile(
    "${path.module}/templates/kube-prometheus-stack/manifests/namespace.yaml", {
      namespace = var.monitoring_namespace
  })
}

resource "kubectl_manifest" "thanos_secret" {
  count = var.enable_prometheus && var.enable_thanos ? 0 : 1

  override_namespace = var.monitoring_namespace
  sensitive_fields   = ["data", "stringData"]
  yaml_body = templatefile(
    "${path.module}/templates/kube-prometheus-stack/manifests/secret.yaml", {
      secret = base64encode(local.thanos_secret)
  })

  depends_on = [kubectl_manifest.monitoring]
}

resource "helm_release" "prometheus_operator" {
  count            = var.enable_prometheus ? 1 : 0
  name             = "prometheus-operator"
  namespace        = var.monitoring_namespace
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = var.kube_prometheus_stack_version
  create_namespace = true
  values = [
    templatefile("${path.module}/templates/kube-prometheus-stack/values.yaml", {
      cluster_name                = var.dns_prefix
      deploy_grafana              = var.enable_grafana
      grafana_admin_password      = var.enable_grafana ? random_password.grafana_password[0].result : ""
      grafana_oauth_client_id     = data.azurerm_key_vault_secret.grafana_oauth_client_id.value
      grafana_oauth_client_secret = data.azurerm_key_vault_secret.grafana_oauth_client_secret.value
      grafana_ms_auth_url         = var.grafana_ms_auth_url
      grafana_ms_token_url        = var.grafana_ms_token_url
      internal_dns_zone           = var.internal_dns_zone
      load_balancer_subnet        = var.internal_lb_subnet
    }),
  ]

  depends_on = [kubectl_manifest.thanos_secret]
}

resource "random_password" "grafana_password" {
  count            = var.enable_grafana ? 1 : 0
  length           = var.grafana_password_length
  special          = true
  override_special = "!#%()-_[]{}<>:?"
}

resource "azurerm_key_vault_secret" "grafana_admin_password" {
  count        = var.enable_grafana ? 1 : 0
  name         = "${var.dns_prefix}-grafana-password"
  value        = random_password.grafana_password[0].result
  key_vault_id = data.azurerm_key_vault.admin.id
}

data "azurerm_key_vault_secret" "grafana_oauth_client_id" {
  name         = var.grafana_oauth_client_id
  key_vault_id = data.azurerm_key_vault.admin.id
}

data "azurerm_key_vault_secret" "grafana_oauth_client_secret" {
  name         = var.grafana_oauth_client_secret
  key_vault_id = data.azurerm_key_vault.admin.id
}
