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
  cluster_issuer_cloudflare          = yamldecode(templatefile("${path.module}/manifests/cloudflare.yaml", { email_address = var.acme_email_address, cloudflare_email_address = var.cloudflare_email_address, api_secret_name = kubernetes_secret_v1.cloudflare_api_key.metadata.0.name }))
  cluster_issuer_letsencrypt         = yamldecode(templatefile("${path.module}/manifests/letsencrypt.yaml", { email_address = var.acme_email_address }))
  cluster_issuer_letsencrypt_staging = yamldecode(templatefile("${path.module}/manifests/letsencrypt_staging.yaml", { email_address = var.acme_email_address }))
}

resource "kubernetes_manifest" "cluster_issuer_letsencrypt_staging" {
  manifest = local.cluster_issuer_letsencrypt_staging
}

resource "kubernetes_manifest" "cluster_issuer_letsencrypt" {
  manifest = local.cluster_issuer_letsencrypt
}

resource "kubernetes_manifest" "cluster_issuer_cloudflare" {
  manifest = local.cluster_issuer_cloudflare
}

resource "kubernetes_secret_v1" "cloudflare_api_key" {
  metadata {
    name      = "cloudflare-api-key"
    namespace = "cert-manager"
  }

  data = {
    "api-token" = var.cloudflare_api_key
  }
}
