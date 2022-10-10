resource "kubernetes_manifest" "gateway_bookinfo_gateway" {
  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind       = "Gateway"
    metadata = {
      name      = "bookinfo-gateway"
      namespace = var.app_namespace
    }
    spec = {
      selector = {
        istio = "ingressgateway"
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
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "virtualservice_bookinfo" {
  manifest = {
    apiVersion = "networking.istio.io/v1alpha3"
    kind       = "VirtualService"
    metadata = {
      name      = "bookinfo"
      namespace = var.app_namespace
    }
    spec = {
      gateways = [
        kubernetes_manifest.gateway_bookinfo_gateway.manifest.metadata.name
      ]
      hosts = [
        "*",
      ]
      http = [
        {
          match = [
            {
              uri = {
                exact = "/productpage"
              }
            },
            {
              uri = {
                prefix = "/static"
              }
            },
            {
              uri = {
                exact = "/login"
              }
            },
            {
              uri = {
                exact = "/logout"
              }
            },
            {
              uri = {
                prefix = "/api/v1/products"
              }
            },
          ]
          route = [
            {
              destination = {
                host = var.productpage_name
                port = {
                  number = 9080
                }
              }
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "gateway_productpage" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1alpha2"
    kind       = "Gateway"
    metadata = {
      annotations = {
        "istio.io/service-account" = var.bookinfo_product_page_name
      }
      name      = var.productpage_name
      namespace = var.app_namespace
    }
    spec = {
      # Use the waypoint proxy
      gatewayClassName = "istio-mesh"
    }
  }
}

resource "kubernetes_manifest" "gateway_reviews" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1alpha2"
    kind       = "Gateway"
    metadata = {
      annotations = {
        "istio.io/service-account" = var.bookinfo_reviews_name
      }
      name      = var.reviews_name
      namespace = var.app_namespace
    }
    spec = {
      # Use the waypoint proxy
      gatewayClassName = "istio-mesh"
    }
  }
}
