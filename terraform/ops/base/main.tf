resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace_name
    labels = {
      istio-injection = "enabled"
    }
  }
}

resource "kubernetes_manifest" "gateway_api_gateway" {
  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "Gateway"
    metadata = {
      namespace = kubernetes_namespace.this.metadata[0].name
      name      = var.gateway-name
    }
    spec = {
      selector = {
        app   = "istio-gateway"
        istio = "gateway"
      }
      servers = [
        {
          hosts = [
            "*",
          ]
          port = {
            name     = "http"
            number   = 80
            protocol = "HTTP"
          }
        }
      ]
    }
  }
}

# resource "kubernetes_config_map" "app" {
#   metadata {
#     name      = var.app-name
#     namespace = kubernetes_namespace.this.metadata[0].name
#   }
#
#   data = {
#     "config.yaml" = file("${path.root}/files/mock_config.yaml")
#   }
# }
#
# resource "kubernetes_deployment" "app" {
#   metadata {
#     name      = var.app-name
#     namespace = kubernetes_namespace.this.metadata[0].name
#     labels = {
#       app = var.app-name
#     }
#   }
#
#   spec {
#     replicas = 1
#
#     selector {
#       match_labels = {
#         app = var.app-name
#       }
#     }
#
#     template {
#       metadata {
#         labels = {
#           app = var.app-name
#         }
#       }
#
#       spec {
#         container {
#           image = "jordimartin/mmock:latest"
#           name  = var.app-name
#
#           resources {
#             limits = {
#               cpu    = "1"
#               memory = "1024Mi"
#             }
#             requests = {
#               cpu    = "250m"
#               memory = "50Mi"
#             }
#           }
#           volume_mount {
#             name       = "config"
#             mount_path = "/config"
#             read_only  = true
#           }
#         }
#         volume {
#           name = "config"
#           config_map {
#             name = kubernetes_config_map.app.metadata[0].name
#             items {
#               key  = "config.yaml"
#               path = "config.yaml"
#             }
#           }
#         }
#       }
#     }
#   }
# }
#
# resource "kubernetes_service" "svc" {
#   metadata {
#     name      = kubernetes_deployment.app.metadata.0.name
#     namespace = kubernetes_namespace.this.metadata[0].name
#   }
#   spec {
#     selector = {
#       app = kubernetes_deployment.app.metadata.0.name
#     }
#     port {
#       name        = "http"
#       port        = 80
#       target_port = 8083
#     }
#
#     type = "ClusterIP"
#   }
# }
#
# resource "kubernetes_manifest" "app_vs" {
#   manifest = {
#     apiVersion = "networking.istio.io/v1beta1"
#     kind       = "VirtualService"
#     metadata = {
#       name      = kubernetes_deployment.app.metadata.0.name
#       namespace = kubernetes_namespace.this.metadata[0].name
#     }
#     spec = {
#       gateways = [
#         "${kubernetes_namespace.this.metadata[0].name}/${var.gateway-name}",
#       ]
#       hosts = [
#         "*",
#       ]
#       http = [
#         {
#           match = [
#             {
#               uri = {
#                 prefix = "/app/"
#               }
#             },
#           ]
#           name = kubernetes_deployment.app.metadata.0.name
#           rewrite = {
#             uri = "/"
#           }
#           timeout = var.max_timeout
#           retries = var.retry_config
#           route = [
#             {
#               destination = {
#                 host = "${kubernetes_deployment.app.metadata.0.name}.${kubernetes_namespace.this.metadata[0].name}.svc.cluster.local"
#                 port = {
#                   number = 80
#                 }
#               }
#             }
#           ]
#         }
#       ]
#     }
#   }
# }
