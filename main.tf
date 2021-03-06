terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.4.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.7.1"
    }
  }
}

locals {
  domain_name = "mcswain.dev"
}

data "terraform_remote_state" "k8s_user_pki" {
  backend = "remote"

  count = (length(var.k8s_client_certificate) > 0 && length(var.k8s_client_key) > 0 && length(var.k8s_cluster_ca_cert) > 0) ? 0 : 1

  config = {
    organization = "McSwainHomeNetwork"
    workspaces = {
      name = "k8s-user-pki"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = var.k8s_host
    client_certificate     = length(var.k8s_client_certificate) > 0 ? var.k8s_client_certificate : data.terraform_remote_state.k8s_user_pki[0].outputs.ci_user_cert_pem
    client_key             = length(var.k8s_client_key) > 0 ? var.k8s_client_key : data.terraform_remote_state.k8s_user_pki[0].outputs.ci_user_key_pem
    cluster_ca_certificate = length(var.k8s_cluster_ca_cert) > 0 ? var.k8s_cluster_ca_cert : data.terraform_remote_state.k8s_user_pki[0].outputs.ca_cert_pem
  }
}

provider "kubernetes" {
  host                   = var.k8s_host
  client_certificate     = length(var.k8s_client_certificate) > 0 ? var.k8s_client_certificate : data.terraform_remote_state.k8s_user_pki[0].outputs.ci_user_cert_pem
  client_key             = length(var.k8s_client_key) > 0 ? var.k8s_client_key : data.terraform_remote_state.k8s_user_pki[0].outputs.ci_user_key_pem
  cluster_ca_certificate = length(var.k8s_cluster_ca_cert) > 0 ? var.k8s_cluster_ca_cert : data.terraform_remote_state.k8s_user_pki[0].outputs.ca_cert_pem
}

module "metallb" {
  source = "./modules/metallb"

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}

module "cert_manager" {
  source = "./modules/cert-manager"

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}

module "cert_manager_clusterissuers" {
  source = "./modules/cert-manager-clusterissuers"

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }

  acme_email_address       = var.acme_email_address
  cloudflare_email_address = var.cloudflare_email_address
  cloudflare_api_key       = var.cloudflare_api_key

  depends_on = [module.cert_manager]
}

module "nginx_ingress" {
  source = "./modules/nginx-ingress"

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }

  depends_on = [module.metallb]
}

module "external_services" {
  source = "./modules/external-services"

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }

  plex_ip           = "192.168.1.138"
  prometheus_ip     = "192.168.1.18"
  grafana_ip        = "192.168.1.18"
  home_assistant_ip = "192.168.1.19"
  domain_name       = local.domain_name

  depends_on = [module.nginx_ingress, module.cert_manager_clusterissuers]
}

module "democratic_csi" {
  source = "./modules/democratic-csi"

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }

  freenas_protocol   = var.freenas_protocol
  freenas_address    = var.freenas_address
  freenas_username   = var.freenas_username
  freenas_password   = var.freenas_password
  freenas_http_port  = var.freenas_http_port
  freenas_iscsi_port = var.freenas_iscsi_port

  depends_on = [module.nginx_ingress, module.cert_manager_clusterissuers]
}

module "redis" {
  source = "./modules/redis"

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}
