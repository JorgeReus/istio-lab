resource "kubernetes_deployment" "stable" {
  metadata {
    name      = "${var.app_name}-${var.stable_version_name}"
    namespace = var.namespace_name
    labels = {
      app     = var.app_name
      version = var.stable_version_name
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app     = var.app_name
          version = var.stable_version_name
        }
      }

      spec {
        container {
          image = "hashicorp/http-echo:latest"
          name  = var.app_name
          args = [
            "-listen=:8080",
            "-text='${var.stable_version_name}'"
          ]
          resources {
            limits = {
              cpu    = "1"
              memory = "500Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "beta" {
  metadata {
    name      = "${var.app_name}-${var.beta_version_name}"
    namespace = var.namespace_name
    labels = {
      app     = var.app_name
      version = var.beta_version_name
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app     = var.app_name
          version = var.beta_version_name
        }
      }

      spec {
        container {
          image = "hashicorp/http-echo:latest"
          name  = var.app_name
          args = [
            "-listen=:8080",
            "-text='${var.beta_version_name}'"
          ]
          resources {
            limits = {
              cpu    = "1"
              memory = "500Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "svc" {
  metadata {
    name      = var.app_name
    namespace = var.namespace_name
  }
  spec {
    selector = {
      app = var.app_name
    }
    port {
      protocol    = "TCP"
      port        = 80
      target_port = 8080
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "vs" {
  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata = {
      name      = var.app_name
      namespace = var.namespace_name
    }
    spec = {
      gateways = [
        "${var.namespace_name}/${var.gateway_name}",
      ]
      hosts = [
        "*",
      ]
      http = [
        {
          match = [
            {
              uri = {
                prefix = "/echo/"
              }
            },
          ]
          name = var.app_name
          rewrite = {
            uri = "/"
          }
          route = [
            {
              destination = {
                host   = "${var.app_name}.${var.namespace_name}.svc.cluster.local"
                subset = var.stable_version_name
              }
              weight = var.stable_weight
            },
            {
              destination = {
                host   = "${var.app_name}.${var.namespace_name}.svc.cluster.local"
                subset = var.beta_version_name
              }
              weight = var.beta_weight
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "dr" {
  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "DestinationRule"
    metadata = {
      name      = var.app_name
      namespace = var.namespace_name
    }
    spec = {
      host = "${var.app_name}.${var.namespace_name}.svc.cluster.local"
      subsets = [
        {
          name = var.stable_version_name
          labels = {
            version = var.stable_version_name
          }
        },
        {
          name = var.beta_version_name
          labels = {
            version = var.beta_version_name
          }
        }
      ]
    }
  }
}
