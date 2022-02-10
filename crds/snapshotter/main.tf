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
  volumesnapshotclasses = yamldecode(file("${path.module}/manifests/snapshot.storage.k8s.io_volumesnapshotclasses.yaml"))
  volumesnapshotcontents = yamldecode(file("${path.module}/manifests/snapshot.storage.k8s.io_volumesnapshotcontents.yaml"))
  volumesnapshots = yamldecode(file("${path.module}/manifests/snapshot.storage.k8s.io_volumesnapshots.yaml"))
}

resource "kubernetes_manifest" "volumesnapshotclasses" {
  manifest = local.volumesnapshotclasses
}

resource "kubernetes_manifest" "volumesnapshotcontents" {
  manifest = local.volumesnapshotcontents
}

resource "kubernetes_manifest" "volumesnapshots" {
  manifest = local.volumesnapshots
}
