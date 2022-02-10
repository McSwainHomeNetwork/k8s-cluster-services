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

locals {
  certificate = yamldecode(file("${path.module}/manifests/certificate.yaml"))
  certificaterequest = yamldecode(file("${path.module}/manifests/certificaterequest.yaml"))
  challenge = yamldecode(file("${path.module}/manifests/challenge.yaml"))
  clusterissuer = yamldecode(file("${path.module}/manifests/clusterissuer.yaml"))
  issuer = yamldecode(file("${path.module}/manifests/issuer.yaml"))
  order = yamldecode(file("${path.module}/manifests/order.yaml"))
}

resource "kubernetes_manifest" "certificate" {
  manifest = local.certificate
}

resource "kubernetes_manifest" "certificaterequest" {
  manifest = local.certificaterequest
}

resource "kubernetes_manifest" "challenge" {
  manifest = local.challenge
}

resource "kubernetes_manifest" "clusterissuer" {
  manifest = local.clusterissuer
}

resource "kubernetes_manifest" "issuer" {
  manifest = local.issuer
}

resource "kubernetes_manifest" "order" {
  manifest = local.order
}
