output "public_ip" {
  value = azurerm_public_ip.this.*.ip_address
}

output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "internal_subnet_id" {
  value = azurerm_subnet.internal.id
}

output "internal_subnet_ip" {
  value = azurerm_subnet.internal.address_prefixes
}

output "internal_subnet" {
  value = azurerm_subnet.internal.name
}

output "nodes_subnet_id" {
  value = azurerm_subnet.nodes.id
}

output "nodes_subnet_ip" {
  value = azurerm_subnet.nodes.address_prefixes
}

output "nodes_subnet" {
  value = azurerm_subnet.nodes.name
}

output "admin_client_certificate" {
  description = "The `client_certificate` in the `azurerm_kubernetes_cluster`'s `kube_admin_config` block.  Base64 encoded public certificate used by clients to authenticate to the Kubernetes cluster."
  sensitive   = true
  value       = try(azurerm_kubernetes_cluster.this.kube_admin_config[0].client_certificate, "")
}

output "admin_client_key" {
  description = "The `client_key` in the `azurerm_kubernetes_cluster`'s `kube_admin_config` block. Base64 encoded private key used by clients to authenticate to the Kubernetes cluster."
  sensitive   = true
  value       = try(azurerm_kubernetes_cluster.this.kube_admin_config[0].client_key, "")
}

output "admin_cluster_ca_certificate" {
  description = "The `cluster_ca_certificate` in the `azurerm_kubernetes_cluster`'s `kube_admin_config` block. Base64 encoded public CA certificate used as the root of trust for the Kubernetes cluster."
  sensitive   = true
  value       = try(azurerm_kubernetes_cluster.this.kube_admin_config[0].cluster_ca_certificate, "")
}

output "admin_host" {
  description = "The `host` in the `azurerm_kubernetes_cluster`'s `kube_admin_config` block. The Kubernetes cluster server host."
  sensitive   = true
  value       = try(azurerm_kubernetes_cluster.this.kube_admin_config[0].host, "")
}
