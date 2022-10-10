resource "kubernetes_manifest" "sa_notsleep" {
  manifest = {
    apiVersion = "v1"
    kind       = "ServiceAccount"
    metadata = {
      name      = var.notsleep_name
      namespace = var.app_namespace
    }
  }
}

resource "kubernetes_service" "notsleep" {
  metadata {
    name      = var.notsleep_name
    namespace = var.app_namespace
    labels = {
      app     = var.notsleep_name
      service = var.notsleep_name
    }
  }
  spec {
    selector = {
      app = var.notsleep_name
    }
    port {
      name = "http"
      port = 80
    }
  }
}

resource "kubernetes_deployment" "notsleep" {
  metadata {
    name      = var.notsleep_name
    namespace = var.app_namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.notsleep_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.notsleep_name
        }
      }

      spec {
        automount_service_account_token = false
        enable_service_links            = false

        affinity {
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              pod_affinity_term {
                label_selector {
                  match_expressions {
                    key      = "app"
                    operator = "In"
                    values = [
                      "productpage",
                    ]
                  }
                }
                topology_key = "kubernetes.io/hostname"
              }
              weight = 100
            }
          }
        }

        container {
          image             = "curlimages/curl"
          image_pull_policy = "IfNotPresent"
          name              = var.notsleep_name
          command = [
            "/bin/sleep",
            "3650d",
          ]

          volume_mount {
            name       = "secret-volume"
            mount_path = "/etc/sleep/tls"
          }
        }
        service_account_name             = var.notsleep_name
        termination_grace_period_seconds = 0

        volume {
          name = "secret-volume"
          secret {
            optional    = true
            secret_name = "${var.notsleep_name}-secret"
          }
        }
      }
    }
  }
}
