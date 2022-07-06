resource "kubernetes_config_map" "app" {
  metadata {
    name      = var.app-name
    namespace = var.namespace_name
  }

  data = {
    "config.yaml" = file("${path.root}/files/mock_config.yaml")
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = var.app-name
    namespace = var.namespace_name
    labels = {
      app = var.app-name
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.app-name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app-name
        }
      }

      spec {
        container {
          image = "jordimartin/mmock:latest"
          name  = var.app-name

          resources {
            limits = {
              cpu    = "1"
              memory = "1024Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
          volume_mount {
            name       = "config"
            mount_path = "/config"
            read_only  = true
          }
        }
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.app.metadata[0].name
            items {
              key  = "config.yaml"
              path = "config.yaml"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "svc" {
  metadata {
    name      = kubernetes_deployment.app.metadata.0.name
    namespace = var.namespace_name
  }
  spec {
    selector = {
      app = kubernetes_deployment.app.metadata.0.name
    }
    port {
      name        = "http"
      port        = 80
      target_port = 8083
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "app_vs" {
  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata = {
      name      = kubernetes_deployment.app.metadata.0.name
      namespace = var.namespace_name
    }
    spec = {
      gateways = [
        "${var.namespace_name}/${var.gateway-name}",
      ]
      hosts = [
        "*",
      ]
      http = [
        {
          match = [
            {
              uri = {
                prefix = "/app/"
              }
            },
          ]
          name = kubernetes_deployment.app.metadata.0.name
          rewrite = {
            uri = "/"
          }
          timeout = var.retry_config.perTryTimeout
          retries = var.retry_config
          route = [
            {
              destination = {
                host = "${var.app-name}.${var.namespace_name}.svc.cluster.local"
                port = {
                  number = 80
                }
              }
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "destinationrule_httpbin" {
  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "DestinationRule"
    metadata = {
      name      = kubernetes_deployment.app.metadata.0.name
      namespace = var.namespace_name
    }
    spec = {
      host = "${var.app-name}.${var.namespace_name}.svc.cluster.local"
      trafficPolicy = {
        outlierDetection = {
          consecutive5xxErrors = 10
          baseEjectionTime     = "10s"
        }
      }
    }
  }
}
