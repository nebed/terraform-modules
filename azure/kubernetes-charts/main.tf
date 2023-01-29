terraform {
  required_providers {
    # https://registry.terraform.io/providers/gavinbunney/kubectl/
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}
