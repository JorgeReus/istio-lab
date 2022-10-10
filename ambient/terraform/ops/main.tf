resource "kubernetes_service" "service_details" {
  metadata {
    name      = var.details_name
    namespace = var.app_namespace
    labels = {
      app     = var.details_name
      service = var.details_name
    }
  }
  spec {
    selector = {
      app = var.details_name
    }
    port {
      name = "http"
      port = 9080
    }
  }
}


resource "kubernetes_service" "service_ratings" {
  metadata {
    name      = var.ratings_name
    namespace = var.app_namespace
    labels = {
      app     = var.ratings_name
      service = var.ratings_name
    }
  }
  spec {
    selector = {
      app = var.ratings_name
    }
    port {
      name = "http"
      port = 9080
    }
  }
}

resource "kubernetes_service" "service_reviews" {
  metadata {
    name      = var.reviews_name
    namespace = var.app_namespace
    labels = {
      app     = var.reviews_name
      service = var.reviews_name
    }
  }
  spec {
    selector = {
      app = var.reviews_name
    }
    port {
      name = "http"
      port = 9080
    }
  }
}


resource "kubernetes_service" "productpage" {
  metadata {
    name      = var.productpage_name
    namespace = var.app_namespace
    labels = {
      app     = var.productpage_name
      service = var.productpage_name
    }
  }
  spec {
    selector = {
      app = var.productpage_name
    }
    port {
      name = "http"
      port = 9080
    }
  }
}

resource "kubernetes_deployment" "details_v1" {
  metadata {
    name      = "details-v1"
    namespace = var.app_namespace

    labels = {
      app     = var.details_name
      version = "v1"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app     = var.details_name
        version = "v1"
      }
    }

    template {
      metadata {
        labels = {
          app     = var.details_name
          version = "v1"
        }
      }

      spec {
        automount_service_account_token = false
        enable_service_links            = false
        container {
          image             = "docker.io/istio/examples-bookinfo-details-v1:1.16.4"
          image_pull_policy = "IfNotPresent"
          name              = var.details_name
          port {
            container_port = 9080
          }

          security_context {
            run_as_user                = 1000
            allow_privilege_escalation = false
          }
        }
        service_account_name = var.bookinfo_details_name
      }
    }
  }
}


resource "kubernetes_deployment" "ratings_v1" {
  metadata {
    name      = "ratings-v1"
    namespace = var.app_namespace

    labels = {
      app     = var.ratings_name
      version = "v1"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app     = var.ratings_name
        version = "v1"
      }
    }

    template {
      metadata {
        labels = {
          app     = var.ratings_name
          version = "v1"
        }
      }

      spec {
        automount_service_account_token = false
        enable_service_links            = false
        container {
          image             = "docker.io/istio/examples-bookinfo-ratings-v1:1.16.4"
          image_pull_policy = "IfNotPresent"
          name              = var.ratings_name
          port {
            container_port = 9080
          }

          security_context {
            run_as_user                = 1000
            allow_privilege_escalation = false
          }
        }
        service_account_name = var.bookinfo_ratings_name
      }
    }
  }
}

resource "kubernetes_deployment" "reviews_v1" {
  metadata {
    name      = "reviews-v1"
    namespace = var.app_namespace

    labels = {
      app     = var.reviews_name
      version = "v1"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app     = var.reviews_name
        version = "v1"
      }
    }

    template {
      metadata {
        labels = {
          app     = var.reviews_name
          version = "v1"
        }
      }

      spec {
        automount_service_account_token = false
        enable_service_links            = false
        container {
          image             = "docker.io/istio/examples-bookinfo-reviews-v1:1.16.4"
          image_pull_policy = "IfNotPresent"
          name              = var.reviews_name
          env {
            name  = "LOG_DIR"
            value = "/tmp/logs"
          }
          port {
            container_port = 9080
          }

          security_context {
            run_as_user                = 1000
            allow_privilege_escalation = false
          }

          volume_mount {
            mount_path = "/tmp"
            name       = "tmp"
          }
          volume_mount {
            mount_path = "/opt/ibm/wlp/output"
            name       = "wlp-output"
          }
        }
        service_account_name = var.bookinfo_reviews_name
        volume {
          empty_dir {}
          name = "wlp-output"
        }

        volume {
          empty_dir {}
          name = "tmp"
        }
      }
    }
  }
}


resource "kubernetes_deployment" "reviews_v2" {
  metadata {
    name      = "reviews-v2"
    namespace = var.app_namespace

    labels = {
      app     = var.reviews_name
      version = "v2"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app     = var.reviews_name
        version = "v2"
      }
    }

    template {
      metadata {
        labels = {
          app     = var.reviews_name
          version = "v2"
        }
      }

      spec {
        automount_service_account_token = false
        enable_service_links            = false
        container {
          image             = "docker.io/istio/examples-bookinfo-reviews-v2:1.16.4"
          image_pull_policy = "IfNotPresent"
          name              = var.reviews_name
          env {
            name  = "LOG_DIR"
            value = "/tmp/logs"
          }
          port {
            container_port = 9080
          }

          security_context {
            run_as_user                = 1000
            allow_privilege_escalation = false
          }

          volume_mount {
            mount_path = "/tmp"
            name       = "tmp"
          }
          volume_mount {
            mount_path = "/opt/ibm/wlp/output"
            name       = "wlp-output"
          }
        }
        service_account_name = var.bookinfo_reviews_name
        volume {
          empty_dir {}
          name = "wlp-output"
        }

        volume {
          empty_dir {}
          name = "tmp"
        }
      }
    }
  }
}



resource "kubernetes_deployment" "reviews_v3" {
  metadata {
    name      = "reviews-v3"
    namespace = var.app_namespace

    labels = {
      app     = var.reviews_name
      version = "v3"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app     = var.reviews_name
        version = "v3"
      }
    }

    template {
      metadata {
        labels = {
          app     = var.reviews_name
          version = "v3"
        }
      }

      spec {
        automount_service_account_token = false
        enable_service_links            = false
        container {
          image             = "docker.io/istio/examples-bookinfo-reviews-v3:1.16.4"
          image_pull_policy = "IfNotPresent"
          name              = var.reviews_name
          env {
            name  = "LOG_DIR"
            value = "/tmp/logs"
          }
          port {
            container_port = 9080
          }

          security_context {
            run_as_user                = 1000
            allow_privilege_escalation = false
          }

          volume_mount {
            mount_path = "/tmp"
            name       = "tmp"
          }
          volume_mount {
            mount_path = "/opt/ibm/wlp/output"
            name       = "wlp-output"
          }
        }
        service_account_name = var.bookinfo_reviews_name
        volume {
          empty_dir {}
          name = "wlp-output"
        }

        volume {
          empty_dir {}
          name = "tmp"
        }
      }
    }
  }
}


resource "kubernetes_deployment" "productpage_v1" {
  metadata {
    name      = "productpage-v1"
    namespace = var.app_namespace

    labels = {
      app     = var.productpage_name
      version = "v1"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app     = var.productpage_name
        version = "v1"
      }
    }

    template {
      metadata {
        labels = {
          app     = var.productpage_name
          version = "v1"
        }
      }

      spec {
        automount_service_account_token = false
        enable_service_links            = false
        container {
          image             = "docker.io/istio/examples-bookinfo-productpage-v1:1.16.4"
          image_pull_policy = "IfNotPresent"
          name              = var.productpage_name
          port {
            container_port = 9080
          }

          security_context {
            run_as_user                = 1000
            allow_privilege_escalation = false
          }

          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }
        }
        service_account_name = var.bookinfo_product_page_name

        volume {
          empty_dir {}
          name = "tmp"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "sa_bookinfo_details" {
  manifest = {
    apiVersion = "v1"
    kind       = "ServiceAccount"
    metadata = {
      name      = var.bookinfo_details_name
      namespace = var.app_namespace
      labels = {
        account = var.details_name
      }
    }
  }
}

resource "kubernetes_manifest" "sa_bookinfo_ratings" {
  manifest = {
    apiVersion = "v1"
    kind       = "ServiceAccount"
    metadata = {
      name      = var.bookinfo_ratings_name
      namespace = var.app_namespace
      labels = {
        account = var.ratings_name
      }
    }
  }
}

resource "kubernetes_manifest" "sa_bookinfo_reviews" {
  manifest = {
    apiVersion = "v1"
    kind       = "ServiceAccount"
    metadata = {
      name      = var.bookinfo_reviews_name
      namespace = var.app_namespace
      labels = {
        account = var.reviews_name
      }
    }
  }
}

resource "kubernetes_manifest" "sa_bookinfo_productopage" {
  manifest = {
    apiVersion = "v1"
    kind       = "ServiceAccount"
    metadata = {
      name      = var.bookinfo_product_page_name
      namespace = var.app_namespace
      labels = {
        account = var.productpage_name
      }
    }
  }
}
