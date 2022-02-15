terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "2.4.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.7.1"
    }
  }
}

resource "helm_release" "redis" {
  name       = "redis"
  repository = "https://usa-reddragon.github.io/helm-charts"
  chart      = "app"
  version    = "0.1.7"
  namespace = "redis"
  create_namespace = true

  set {
    name  = "image.repository"
    value = "redis"
    type  = "string"
  }

  set {
    name  = "image.tag"
    value = "6.2-alpine"
    type  = "string"
  }

  set {
    name  = "ingress.enabled"
    value = "false"
  }

  set {
    name  = "service.ports[0].name"
    value = "redis"
    type  = "string"
  }

  set {
    name  = "service.ports[0].port"
    value = "6379"
  }

}
