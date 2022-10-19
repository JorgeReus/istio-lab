resource "kubernetes_deployment" "petstore" {
  metadata {
    name      = "petstore"
    namespace = "default"
    labels = {
      app = "petstore"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "petstore"
      }
    }

    template {
      metadata {
        labels = {
          app = "petstore"
        }
      }

      spec {
        container {
          image = "soloio/petstore-example:latest"
          name  = "petstore"
          port {
            container_port = 8080
            name           = "http"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "petstore" {
  metadata {
    name      = "petstore"
    namespace = "default"
  }
  spec {
    selector = {
      app = "petstore"
    }
    session_affinity = "ClientIP"
    port {
      port     = 8080
      protocol = "TCP"
      name     = "http"
    }

    type = "ClusterIP"
  }
}
