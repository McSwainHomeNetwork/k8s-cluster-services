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

data "terraform_remote_state" "k8s_ci_roles" {
  backend = "remote"

  count = (length(var.k8s_host) > 0 || length(var.k8s_token) > 0 || length(var.k8s_cluster_ca_cert) > 0) ? 0 : 1

  config = {
    organization = "McSwainHomeNetwork"
    workspaces = {
      name = "k8s-ci-roles"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = length(var.k8s_host) > 0 ? var.k8s_host : data.terraform_remote_state.k8s_ci_roles[0].outputs.host
    token                  = length(var.k8s_token) > 0 ? var.k8s_token : data.terraform_remote_state.k8s_ci_roles[0].outputs.token
    cluster_ca_certificate = length(var.k8s_cluster_ca_cert) > 0 ? var.k8s_cluster_ca_cert : data.terraform_remote_state.k8s_ci_roles[0].outputs.cluster_ca_certificate
  }
}

provider "kubernetes" {
  host                   = length(var.k8s_host) > 0 ? var.k8s_host : data.terraform_remote_state.k8s_ci_roles[0].outputs.host
  token                  = length(var.k8s_token) > 0 ? var.k8s_token : data.terraform_remote_state.k8s_ci_roles[0].outputs.token
  cluster_ca_certificate = length(var.k8s_cluster_ca_cert) > 0 ? var.k8s_cluster_ca_cert : data.terraform_remote_state.k8s_ci_roles[0].outputs.cluster_ca_certificate
}

module "metallb" {
  source = "./modules/metallb"

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}

module "nginx-ingress" {
  source = "./modules/nginx-ingress"

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }

  depends_on = [module.metallb]
}
