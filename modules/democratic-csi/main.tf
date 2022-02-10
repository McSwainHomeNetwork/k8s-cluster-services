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

resource "helm_release" "snapshot_controller" {
  name       = "snapshot-controller"
  repository = "https://democratic-csi.github.io/charts/"
  chart      = "snapshot-controller"
  version    = "0.1.0"
  namespace = "kube-system"

  set {
    name = "validatingWebhook.enabled"
    value = "false"
  }

  set {
    name  = "validatingWebhook.replicaCount"
    value = "1"
  }
}

locals {
  templates = {
    "freenas_protocol" = var.freenas_protocol
    "freenas_address" = var.freenas_address
    "freenas_username" = var.freenas_username
    "freenas_password" = var.freenas_password
    "freenas_http_port" = var.freenas_http_port
    "freenas_iscsi_port" = var.freenas_iscsi_port
  }
}

resource "helm_release" "democratic_csi_nfs" {
  name       = "democratic-csi-nfs"
  repository = "https://democratic-csi.github.io/charts/"
  chart      = "democratic-csi"
  version    = "1.7.1"
  namespace = "democratic-csi"
  create_namespace = true

  values = [templatefile("nfs.yaml"), local.templates]

  depends_on = [helm_release.snapshot_controller]
}

resource "helm_release" "democratic_csi_iscsi" {
  name       = "democratic-csi-iscsi"
  repository = "https://democratic-csi.github.io/charts/"
  chart      = "democratic-csi"
  version    = "1.7.1"
  namespace = "democratic-csi"

  values = [templatefile("iscsi.yaml"), local.templates]

  depends_on = [helm_release.snapshot_controller, helm_release.democratic_csi_nfs]
}
