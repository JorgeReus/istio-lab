resource "kubernetes_namespace" "istio_system" {
  # depends_on = [helm_release.metallb]
  metadata {
    name = "istio-system"
  }
}

resource "kubernetes_namespace" "app_ns" {
  metadata {
    name = "ambient-test"
    labels = {
      "istio.io/dataplane-mode" = "ambient"
    }
  }
}

resource "helm_release" "istio_base" {
  name      = "istio-base"
  chart     = "${path.root}/istio-${var.istio_version}/manifests/charts/base/"
  namespace = kubernetes_namespace.istio_system.metadata[0].name

  cleanup_on_fail = true
  values = [
    file("${path.root}/files/global.yaml"),
    file("${path.root}/files/base.yaml")
  ]
}

resource "helm_release" "istio_control" {
  depends_on = [
    helm_release.istio_base
  ]
  name            = "istio-control"
  chart           = "${path.root}/istio-${var.istio_version}/manifests/charts/istio-control/istio-discovery/"
  namespace       = kubernetes_namespace.istio_system.metadata[0].name
  cleanup_on_fail = true
  values = [
    file("${path.root}/files/global.yaml"),
    file("${path.root}/files/istio-control.yaml")
  ]
}

resource "helm_release" "istio_cni" {
  depends_on = [
    helm_release.istio_control
  ]
  name            = "istio-cni"
  chart           = "${path.root}/istio-${var.istio_version}/manifests/charts/istio-cni/"
  namespace       = kubernetes_namespace.istio_system.metadata[0].name
  cleanup_on_fail = true
  values = [
    file("${path.root}/files/global.yaml"),
    file("${path.root}/files/cni.yaml")
  ]
}

resource "helm_release" "gateways" {
  depends_on = [
    helm_release.istio_cni,
    # kubectl_manifest.metallb_advertisement,
  ]
  name            = "istio-gateways"
  chart           = "${path.root}/istio-${var.istio_version}/manifests/charts/gateways/istio-ingress/"
  namespace       = kubernetes_namespace.istio_system.metadata[0].name
  cleanup_on_fail = true
  values = [
    file("${path.root}/files/global.yaml"),
    templatefile("${path.root}/files/gateways.yaml", {
      ingressgateway-name = "istio-ingressgateway"
    })
  ]
}
