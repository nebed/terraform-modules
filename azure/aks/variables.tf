variable "env" {
  description = "environment configuration, prefix, location and resource group"
  type = object({
    prefix         = string
    location       = string
    resource_group = string
    tags           = map(string)
  })
}

variable "enable_k8s_infra_peering" {
  description = "enable peering to k8s-infra cluster"
  default     = true
}

variable "registration_enabled" {
  description = "enable vm registration on private  dns zone for aks cluster"
  default     = false
}

variable "ingress_dns" {
  type = object({
    name           = string
    resource_group = string
  })
  description = "values for your private dns zone"
  default = {
    name           = "int.myzone.testsample"
    resource_group = "central-rg"
  }
}

variable "postgres_dns" {
  type = object({
    name           = string
    resource_group = string
  })
  description = "values for postgres private dns zone"
  default = {
    name           = "privatelink.postgres.database.azure.com"
    resource_group = "central-rg"
  }
}

variable "mssql_dns" {
  type = object({
    name           = string
    resource_group = string
  })
  description = "values for postgres private dns zone"
  default = {
    name           = "privatelink.database.windows.net"
    resource_group = "central-rg"
  }
}

variable "azurewebsites_dns" {
  type = object({
    name           = string
    resource_group = string
  })
  description = "values for Azure Websites private dns zone"
  default = {
    name           = "privatelink.azurewebsites.net"
    resource_group = "central-rg"
  }
}

variable "redis_dns" {
  type = object({
    name           = string
    resource_group = string
  })
  description = "values for Azure redis private dns zone"
  default = {
    name           = "privatelink.redis.cache.windows.net"
    resource_group = "central-rg"
  }
}

variable "internal_subnet" {

}

variable "internal_subnet_service_endpoints" {
  description = "Service Endpoints to enable for the subnet"
  default     = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql", "Microsoft.ContainerRegistry"]
}

variable "nodes_subnet" {

}

variable "nodes_subnet_service_endpoints" {
  description = "Service Endpoints to enable for the subnet"
  default     = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql", "Microsoft.ContainerRegistry"]
}

variable "network_address_space" {
  description = "Address Space for Kubernetes Vnet"
}

variable "central_vnet" {
  type = object({
    name           = string
    resource_group = string
  })
  description = "Shared services vnet for VPN"
  default = {
    name           = "central-vnet"
    resource_group = "central-rg"
  }
}

variable "infra_vnet" {
  type = object({
    name           = string
    resource_group = string
  })
  description = "Central Infrastructure Vnet"
  default = {
    name           = "infra-vnet"
    resource_group = "infra-rg"
  }
}

variable "dns_rg" {
  default = "k8s-dev-rg"
}

variable "enforce_private_link_endpoint_network_policies" {
  default = true
}

variable "use_remote_gateways" {
  default = true
}

variable "allow_forwarded_traffic" {
  default = true
}

variable "allow_gateway_transit" {
  default = true
}

variable "admin_keyvault" {
  default = {
    name = "test-myadminkeyvault"
    rg   = "central-rg"
  }
}

variable "ssh_secret_name" {
  default = "aks-nodes-ssh-public-key"
}

variable "default_node_pool_vm_size" {
  description = "VM Size for default node pool kubernetes cluster"
  default     = "Standard_B2s"
}

variable "private_cluster_enabled" {
  description = "Enable private cluster on Kubernetes"
  default     = true
}

variable "api_server_authorized_ip_ranges" {
  description = "Enable Api server authorized IP ranges"
  default     = null
}

variable "rbac_enabled" {
  description = "Enable Role Based Access Control on the Cluster"
  default     = true
}

variable "k8s_sku_tier" {
  description = "SKU Teir of Kubernetes Cluster"
  default     = "Free"
}

variable "node_pool_type" {
  description = "type of nodepools Availability set ot Virtual machine Scale set"
  default     = "VirtualMachineScaleSets"
}

variable "default_node_pool_name" {
  default = "system"
}

variable "default_node_pool_node_count" {
  default = 1
}

variable "availability_zones" {
  description = "Avaialability Zones to use for Nodes"
  default     = [1, 2]
}

variable "load_balancer_sku" {
  description = "Type of Load Balanbcer to  use"
  default     = "standard"
}

variable "managed_ip_count" {
  default = 2
}

variable "network_plugin" {
  default = "kubenet"
}

variable "network_policy" {
  default = "calico"
}

variable "kubernetes_version" {
  default = "1.23.8"
}

variable "capacity_reservation_group_id" {
  default = null
}

variable "default_node_pool_os_sku" {
  default = "Ubuntu"
}

variable "default_node_pool_disk_size" {
  default = 30
}

variable "default_node_pool_autoscaling" {
  default = false
}

variable "default_node_pool_disk_type" {
  default = "Managed"
}

variable "default_node_pool_ultra_ssd" {
  default = false
}

variable "default_max_pods" {
  default = 80
}

variable "node_lables" {
  default = null
}

variable "critical_addons" {
  default = null
}

variable "ssh_username" {
  default = "azureuser"
}

variable "outbound_type" {
  description = "The outbound (egress) routing method which should be used for this Kubernetes Cluster."
  type        = string
  default     = "loadBalancer"
}

variable "pod_cidr" {
  description = "The CIDR to use for pod IP addresses."
  type        = string
  default     = null
}

variable "service_cidr" {
  description = "The Network Range used by the Kubernetes service."
  type        = string
  default     = null
}

variable "dns_service_ip" {
  description = "IP address within the Kubernetes service address range that will be used by cluster"
  type        = string
  default     = null
}

variable "docker_bridge_cidr" {
  description = "IP address (in CIDR notation) used as the Docker bridge IP address on nodes."
  type        = string
  default     = null
}

variable "default_node_max" {
  default = 4
}

variable "aad_managed_rbac" {
  default = true
}

variable "admin_group_name" {
  description = "Azure AD group for aks admin"
  default     = "DevOps"
}

variable "azure_rbac_enabled" {
  default = true
}

variable "rbac_aad_client_app_id" {
  default = null
}

variable "rbac_aad_server_app_id" {
  default = null
}

variable "rbac_aad_server_app_secret" {
  default = null
}

variable "node_pools" {
  default = {}
}

variable "enable_public_ingress" {
  default = false
}
