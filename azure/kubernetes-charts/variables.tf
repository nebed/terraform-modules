variable "dns_prefix" { type = string }

variable "tags" {
  type    = map(string)
  default = {}
}

variable "enable_base_domain_cert" {
  default = false
}

variable "enable_internal_ingress" {
  default = true
}

variable "enable_public_ingress" {
  default = false
}

variable "enable_grafana" {
  default = false
}

variable "grafana_password_length" {
  default = 14
}

variable "grafana_oauth_client_id" {
  default = "grafana-oauth-client-id"
}

variable "grafana_oauth_client_secret" {
  default = "grafana-oauth-client-secret"
}

variable "grafana_ms_auth_url" {

}

variable "grafana_ms_token_url" {

}

variable "enable_prometheus" {
  default = true
}

variable "kube_prometheus_stack_version" {
  default = "42.0.0"
}

variable "monitoring_namespace" {
  default = "monitoring"
}

variable "enable_thanos" {
  default = false
}

variable "thanos_chart_version" {
  default = "11.5.4"
}

variable "storage_account_name" {
}

variable "thanosstores" {
  default = {}
}

variable "internal_dns_zone" {
  default = "int.myzone.testsample"
}

variable "internal_ingress" {
  default = {
    chart_version    = "4.2.1"
    name             = "ingress-nginx-internal"
    namespace        = "ingress-nginx-internal"
    class_name       = "ingress-nginx-internal"
    controller_value = "k8s.io/ingress-nginx-internal"

    internal_dns_zone    = "int.myzone.testsample"
    internal_dns_zone_rg = "central-rg"
  }
}

variable "internal_lb_ip" { type = string }
variable "internal_lb_subnet" { type = string }
variable "internal_lb_rg" { type = string }

variable "internal_ingress_lb_dns_record" {
  type        = string
  description = "Internal Ingress load balancer *.int.myzone.testsample DNS A record"
  default     = ""
}

variable "public_ingress" {
  default = {
    chart_version    = "4.2.1"
    name             = "ingress-nginx-public"
    namespace        = "ingress-nginx-public"
    class_name       = "ingress-nginx-public"
    controller_value = "k8s.io/ingress-nginx-public"
  }
}

variable "public_lb_ip" {

}

variable "public_lb_rg" {

}

variable "enable_cert_manager" {
  default = true
}

variable "dnsmadeeasy" {
  default = {
    chart_version   = "4.7.2"
    api_key_name    = "dnsmadeeasy-api-key"
    secret_key_name = "dnsmadeeasy-secret-key"
  }
}

variable "cert_manager" {
  default = {
    # https://github.com/cert-manager/cert-manager/blob/v1.9.1/deploy/charts/cert-manager/values.yaml
    chart_version = "v1.9.1"
    name          = "cert-manager"
    namespace     = "cert-manager"
    ingress_certs = {
      internal = "default-internal-ingress-tls"
      public   = "default-public-ingress-tls"
    }
    issuers = {
      dnsmadeeasy = {
        name        = "letsencrypt-dnsmadeeasy"
        server      = "https://acme-v02.api.letsencrypt.org/directory"
        email       = "devops@myzone.testsample"
        secret_name = "letsencrypt-issuer-account-key"
        group_name  = "acme.myzone.testsample"
      }
    }
  }
}

variable "admin_keyvault" {
  default = {
    name = "test-myadminkeyvault"
    rg   = "central-rg"
  }
}
