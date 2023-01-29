data "azurerm_client_config" "current" {
}

resource "azurerm_user_assigned_identity" "this" {
  name                = "${local.prefix}-identity"
  resource_group_name = var.env.resource_group
  location            = var.env.location
}

resource "azurerm_role_assignment" "dns" {
  scope                = data.azurerm_private_dns_zone.k8s.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

resource "azurerm_role_assignment" "kubelet" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "KubeletIdentity"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

resource "azurerm_role_assignment" "velero" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Velero"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

resource "azurerm_role_assignment" "network" {
  scope                = data.azurerm_resource_group.this.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

resource "azurerm_role_assignment" "storage_account" {
  scope                = data.azurerm_resource_group.central.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

resource "azurerm_role_assignment" "acr" {
  scope                = data.azurerm_resource_group.central.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

data "azurerm_resource_group" "central" {
  name = var.central_vnet.resource_group
}

data "azurerm_resource_group" "this" {
  name = var.env.resource_group
}

data "azuread_group" "k8s_dev_users" {
  display_name     = "Kubernetes DEV Users"
  security_enabled = true
}

resource "azurerm_role_assignment" "k8s_dev_users_cluster_user" {
  scope                = azurerm_kubernetes_cluster.this.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = data.azuread_group.k8s_dev_users.object_id
}
