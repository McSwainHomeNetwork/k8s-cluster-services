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

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "1.7.1"
  namespace        = "cert-manager"
  create_namespace = true

  # We need CRDs installed externally before this run, because the plan will check resources like Certificate against CRDs.
  set {
    name  = "installCRDs"
    value = "false"
  }
}
