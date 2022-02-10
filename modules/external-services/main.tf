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

resource "kubernetes_namespace_v1" "static_services" {
  metadata {
    name = "static-services"
  }
}

locals {
  plex_port = 32400
  home_assistant_port = 8123

  domain_name_safe = replace(var.domain_name, ".", "-")
}

resource "kubernetes_endpoints_v1" "plex" {
  metadata {
    name = "plex-${local.domain_name_safe}"
    namespace = kubernetes_namespace_v1.static_services.metadata.0.name
  }
  
  subset {
    address {
      ip = var.plex_ip
    }

    port {
      name     = "plex"
      port     = local.plex_port
      protocol = "TCP"
    }
  }
}

resource "kubernetes_service_v1" "plex" {
  metadata {
    name = kubernetes_endpoints_v1.plex.metadata.0.name
    namespace = kubernetes_namespace_v1.static_services.metadata.0.name
  }

  spec {
    port {
      port        = local.plex_port
      target_port = local.plex_port
    }
  }
}

resource "kubernetes_ingress_v1" "plex" {
  metadata {
    name = "plex-${local.domain_name_safe}"
    namespace = kubernetes_namespace_v1.static_services.metadata.0.name

    annotations = {
      "cert-manager.io/cluster-issuer" = "cloudflare"
      "kubernetes.io/ingress.class" = "nginx"
      "kubernetes.io/tls-acme" = "true"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
    }
  }

  spec {
    rule {
      host = "plex.${var.domain_name}"
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.plex.metadata.0.name
              port {
                number = local.plex_port
              }
            }
          }
        }
      }
    }

    tls {
      secret_name = "plex-${local.domain_name_safe}-tls"
      hosts = [ "plex.${var.domain_name}" ]
    }
  }
}

resource "kubernetes_endpoints_v1" "home_assistant" {
  metadata {
    name = "home-${local.domain_name_safe}"
    namespace = kubernetes_namespace_v1.static_services.metadata.0.name
  }
  
  subset {
    address {
      ip = var.home_assistant_ip
    }

    port {
      name     = "home-assistant"
      port     = local.home_assistant_port
      protocol = "TCP"
    }
  }
}

resource "kubernetes_service_v1" "home_assistant" {
  metadata {
    name = kubernetes_endpoints_v1.home_assistant.metadata.0.name
    namespace = kubernetes_namespace_v1.static_services.metadata.0.name
  }

  spec {
    port {
      port        = local.home_assistant_port
      target_port = local.home_assistant_port
    }
  }
}

resource "kubernetes_ingress_v1" "home_assistant" {
  metadata {
    name = "home-${local.domain_name_safe}"
    namespace = kubernetes_namespace_v1.static_services.metadata.0.name

    annotations = {
      "cert-manager.io/cluster-issuer" = "cloudflare"
      "kubernetes.io/ingress.class" = "nginx"
      "kubernetes.io/tls-acme" = "true"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
    }
  }

  spec {
    rule {
      host = "home.${var.domain_name}"
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.home_assistant.metadata.0.name
              port {
                number = local.home_assistant_port
              }
            }
          }
        }
      }
    }

    tls {
      secret_name = "home-${local.domain_name_safe}-tls"
      hosts = [ "home.${var.domain_name}" ]
    }
  }
}
