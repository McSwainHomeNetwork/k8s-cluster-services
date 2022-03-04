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
  grafana_port = 3000
  prometheus_port = 9090

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

resource "kubernetes_endpoints_v1" "grafana" {
  metadata {
    name = "grafana-${local.domain_name_safe}"
    namespace = kubernetes_namespace_v1.static_services.metadata.0.name
  }
  
  subset {
    address {
      ip = var.grafana_ip
    }

    port {
      name     = "grafana"
      port     = local.grafana_port
      protocol = "TCP"
    }
  }
}

resource "kubernetes_service_v1" "grafana" {
  metadata {
    name = kubernetes_endpoints_v1.grafana.metadata.0.name
    namespace = kubernetes_namespace_v1.static_services.metadata.0.name
  }

  spec {
    port {
      port        = local.grafana_port
      target_port = local.grafana_port
    }
  }
}

resource "kubernetes_ingress_v1" "grafana" {
  metadata {
    name = "grafana-${local.domain_name_safe}"
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
      host = "grafana.${var.domain_name}"
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.grafana.metadata.0.name
              port {
                number = local.grafana_port
              }
            }
          }
        }
      }
    }

    tls {
      secret_name = "grafana-${local.domain_name_safe}-tls"
      hosts = [ "grafana.${var.domain_name}" ]
    }
  }
}

resource "kubernetes_endpoints_v1" "prometheus" {
  metadata {
    name = "prometheus-${local.domain_name_safe}"
    namespace = kubernetes_namespace_v1.static_services.metadata.0.name
  }
  
  subset {
    address {
      ip = var.prometheus_ip
    }

    port {
      name     = "prometheus"
      port     = local.prometheus_port
      protocol = "TCP"
    }
  }
}

resource "kubernetes_service_v1" "prometheus" {
  metadata {
    name = kubernetes_endpoints_v1.prometheus.metadata.0.name
    namespace = kubernetes_namespace_v1.static_services.metadata.0.name
  }

  spec {
    port {
      port        = local.prometheus_port
      target_port = local.prometheus_port
    }
  }
}

resource "kubernetes_ingress_v1" "prometheus" {
  metadata {
    name = "prometheus-${local.domain_name_safe}"
    namespace = kubernetes_namespace_v1.static_services.metadata.0.name

    annotations = {
      "cert-manager.io/cluster-issuer" = "cloudflare"
      "kubernetes.io/ingress.class" = "nginx"
      "kubernetes.io/tls-acme" = "true"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/auth-signin" = "https://auth.mcswain.dev/oauth2/start?rd=$scheme://$http_host$escaped_request_uri"
      "nginx.ingress.kubernetes.io/auth-url" = "https://auth.mcswain.dev/oauth2/auth"
    }
  }

  spec {
    rule {
      host = "prometheus.${var.domain_name}"
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.prometheus.metadata.0.name
              port {
                number = local.prometheus_port
              }
            }
          }
        }
      }
    }

    tls {
      secret_name = "prometheus-${local.domain_name_safe}-tls"
      hosts = [ "prometheus.${var.domain_name}" ]
    }
  }
}
