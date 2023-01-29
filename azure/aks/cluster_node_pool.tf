resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each = var.node_pools

  name                   = each.value.name
  kubernetes_cluster_id  = azurerm_kubernetes_cluster.this.id
  vm_size                = each.value.vm_size
  node_count             = each.value.node_count
  enable_auto_scaling    = try(each.value["auto_scaling"], false)
  enable_host_encryption = try(each.value["host_encryption"], false)
  max_pods               = try(each.value["max_pods"], 80)
  mode                   = try(each.value["mode"], "User")
  node_labels            = try(each.value["node_labels"], null)
  node_taints            = try(each.value["node_taints"], null)
  orchestrator_version   = try(each.value["orchestrator_version"], null)
  pod_subnet_id          = try(each.value["pod_subnet_id"], null)
  os_type                = try(each.value["os"], "Linux")
  os_disk_size_gb        = try(each.value["disk_size"], 120)
  os_disk_type           = try(each.value["disk_type"], "Managed")
  os_sku                 = try(each.value["os_sku"], "Ubuntu")
  vnet_subnet_id         = try(each.value["vnet_subnet_id"], azurerm_subnet.nodes.id)
  zones                  = var.load_balancer_sku == "standard" ? var.availability_zones : null
  max_count              = try(each.value["max_count"], null)
  min_count              = try(each.value["min_count"], null)
  ultra_ssd_enabled      = try(each.value["ultra_ssd"], false)
  priority               = try(each.value["priority"], "Regular")

  tags = var.env.tags

  lifecycle {
    ignore_changes = [
      node_count,
      tags
    ]
  }
}
