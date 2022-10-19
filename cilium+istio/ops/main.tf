resource "kubernetes_manifest" "vs_petstore" {
  manifest = {
    apiVersion = "gateway.solo.io/v1"
    kind       = "VirtualService"
    metadata = {
      name      = "petstore"
      namespace = var.gloo_ns
    }
    spec = {
      virtualHost = {
        domains = [
          "*",
        ]
        routes = [
          {
            matchers = [
              {
                prefix = "/"
              },
            ]
            routeAction = {
              single = {
                kube = {
                  port = 8080
                  ref = {
                    name      = "petstore"
                    namespace = var.app_ns
                  }
                }
              }
            }
          }
        ]
      }
    }
  }
}

resource "kubernetes_manifest" "sa_a" {
  manifest = {
    apiVersion = "v1"
    kind       = "ServiceAccount"
    metadata = {
      name      = "svc-a"
      namespace = var.app_ns
    }
  }
}

resource "kubernetes_deployment" "test_pod" {
  metadata {
    name      = "test-pod"
    namespace = var.app_ns
    labels = {
      app = "test-pod"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "test-pod"
      }
    }

    template {
      metadata {
        labels = {
          app = "test-pod"
        }
      }

      spec {
        container {
          image   = "fedora:30"
          name    = "sleep"
          command = ["sleep", "10h"]
        }
        service_account_name = kubernetes_manifest.sa_a.manifest.metadata.name
      }
    }
  }
}
