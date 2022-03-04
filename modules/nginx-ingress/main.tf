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

resource "helm_release" "nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.0.17"
  namespace        = "ingress-nginx"
  create_namespace = true

  set {
    name  = "ingressClassResource.default"
    value = "true"
  }

  set {
    name  = "metrics.enabled"
    value = "true"
  }

  set {
    name  = "metrics.service.annotations.prometheus\\.io/port"
    value = "10254"
    type  = "string"
  }

  set {
    name  = "metrics.service.annotations.prometheus\\.io/scrape"
    value = "true"
  }

  set {
    name  = "defaultBackend.enabled"
    value = "true"
  }
}
