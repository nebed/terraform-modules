terraform {
  required_providers {
    # https://registry.terraform.io/providers/hashicorp/azurerm/
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.17.0"
    }
    # https://registry.terraform.io/providers/gavinbunney/kubectl/
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}
