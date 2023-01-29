data "azurerm_key_vault" "admin" {
  name                = var.admin_keyvault.name
  resource_group_name = var.admin_keyvault.rg
}

data "azurerm_key_vault_secret" "ssh_pub_key" {
  name         = var.ssh_secret_name
  key_vault_id = data.azurerm_key_vault.admin.id
}

resource "azurerm_kubernetes_cluster" "this" {
  name                              = local.prefix
  location                          = var.env.location
  resource_group_name               = var.env.resource_group
  dns_prefix                        = var.private_cluster_enabled ? null : local.prefix
  dns_prefix_private_cluster        = var.private_cluster_enabled ? local.prefix : null
  private_cluster_enabled           = var.private_cluster_enabled
  private_dns_zone_id               = data.azurerm_private_dns_zone.k8s.id
  api_server_authorized_ip_ranges   = var.api_server_authorized_ip_ranges
  role_based_access_control_enabled = var.rbac_enabled
  sku_tier                          = var.k8s_sku_tier
  node_resource_group               = "${local.prefix}-nodes-rg"
  kubernetes_version                = var.kubernetes_version

  linux_profile {
    admin_username = var.ssh_username
    ssh_key {
      key_data = data.azurerm_key_vault_secret.ssh_pub_key.value
    }
  }

  default_node_pool {
    name                          = var.default_node_pool_name
    node_count                    = var.default_node_pool_node_count
    vm_size                       = var.default_node_pool_vm_size
    type                          = var.node_pool_type
    capacity_reservation_group_id = var.capacity_reservation_group_id
    enable_auto_scaling           = var.default_node_pool_autoscaling
    os_disk_size_gb               = var.default_node_pool_disk_size
    os_disk_type                  = var.default_node_pool_disk_type
    ultra_ssd_enabled             = var.default_node_pool_ultra_ssd
    os_sku                        = var.default_node_pool_os_sku
    max_pods                      = var.default_max_pods
    node_labels                   = var.node_lables
    only_critical_addons_enabled  = var.critical_addons
    max_count                     = var.default_node_pool_autoscaling ? var.default_node_max : null
    min_count                     = var.default_node_pool_autoscaling ? var.default_node_pool_node_count : null
    tags                          = var.env.tags
    vnet_subnet_id                = azurerm_subnet.nodes.id
    zones                         = var.load_balancer_sku == "standard" ? var.availability_zones : null
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }

  kubelet_identity {
    client_id                 = azurerm_user_assigned_identity.this.client_id
    object_id                 = azurerm_user_assigned_identity.this.principal_id
    user_assigned_identity_id = azurerm_user_assigned_identity.this.id
  }

  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = var.network_plugin == "azure" ? var.network_policy : null
    dns_service_ip     = var.dns_service_ip
    docker_bridge_cidr = var.docker_bridge_cidr
    outbound_type      = var.outbound_type
    pod_cidr           = var.pod_cidr
    service_cidr       = var.service_cidr
    load_balancer_sku  = var.load_balancer_sku

    dynamic "load_balancer_profile" {
      for_each = var.load_balancer_sku == "standard" ? ["standard"] : []
      content {
        managed_outbound_ip_count = var.load_balancer_sku == "standard" ? var.managed_ip_count : null
      }
    }
  }

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.rbac_enabled ? ["rbac"] : []
    content {
      managed                = var.aad_managed_rbac
      azure_rbac_enabled     = var.aad_managed_rbac ? var.azure_rbac_enabled : null
      admin_group_object_ids = var.aad_managed_rbac ? [data.azuread_group.admin.object_id] : null
      client_app_id          = var.aad_managed_rbac ? null : var.rbac_aad_client_app_id
      server_app_id          = var.aad_managed_rbac ? null : var.rbac_aad_server_app_id
      server_app_secret      = var.aad_managed_rbac ? null : var.rbac_aad_server_app_secret
    }
  }

  tags = var.env.tags

  depends_on = [
    azurerm_role_assignment.dns,
    azurerm_role_assignment.kubelet,
  ]

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      default_node_pool[0].tags
    ]
  }
}

data "azuread_group" "admin" {
  display_name = var.admin_group_name
}
