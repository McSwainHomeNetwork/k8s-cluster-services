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

resource "kubernetes_namespace_v1" "democratic_csi" {
  metadata {
    name = "democratic-csi"
  }
}

resource "kubernetes_pod_security_policy_v1beta1" "unrestricted" {
  metadata {
    name = "democratic-csi-unrestricted"
    namespace = kubernetes_namespace_v1.democratic_csi.metadata.0.name
  }
  spec {
    privileged                 = true
    allow_privilege_escalation = false

    allowed_capabilities = [
      "SYS_ADMIN"
    ]

    volumes = [
      "configMap",
      "emptyDir",
      "projected",
      "secret",
      "downwardAPI",
      "persistentVolumeClaim",
    ]

    run_as_user {
      rule = "RunAsAny"
    }

    se_linux {
      rule = "RunAsAny"
    }

    supplemental_groups {
      rule = "RunAsAny"
    }

    fs_group {
      rule = "RunAsAny"
    }

    read_only_root_filesystem = false
  }
}

resource "helm_release" "democratic_csi_nfs" {
  name       = "democratic-csi-nfs"
  repository = "https://democratic-csi.github.io/charts/"
  chart      = "democratic-csi"
  version    = "0.10.0"
  namespace = kubernetes_namespace_v1.democratic_csi.metadata.0.name

  values = [templatefile("${path.module}/nfs.yaml", local.templates)]

  depends_on = [helm_release.snapshot_controller, kubernetes_pod_security_policy_v1beta1.unrestricted]
}

resource "helm_release" "democratic_csi_iscsi" {
  name       = "democratic-csi-iscsi"
  repository = "https://democratic-csi.github.io/charts/"
  chart      = "democratic-csi"
  version    = "0.1.0"
  namespace = kubernetes_namespace_v1.democratic_csi.metadata.0.name

  values = [templatefile("${path.module}/iscsi.yaml", local.templates)]

  depends_on = [helm_release.snapshot_controller, kubernetes_pod_security_policy_v1beta1.unrestricted]
}
