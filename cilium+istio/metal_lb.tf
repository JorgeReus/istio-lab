resource "kubernetes_namespace" "metallb" {
  metadata {
    name = "metallb-system"
  }
}

resource "helm_release" "metallb" {
  repository = "https://metallb.github.io/metallb"
  version    = var.metallb_chart_version
  name       = "metallb"
  chart      = "metallb"
  namespace  = kubernetes_namespace.metallb.metadata[0].name
}

resource "kubectl_manifest" "metallb_ip_ranges" {
  depends_on = [
    helm_release.metallb
  ]
  wait      = true
  force_new = true
  yaml_body = templatefile("./files/metallb/ip-pool.yaml", {
    namespace     = kubernetes_namespace.metallb.metadata[0].name
    address-range = var.metallb_addr_range
  })
}

resource "kubectl_manifest" "metallb_advertisement" {
  depends_on = [
    kubectl_manifest.metallb_ip_ranges,
    helm_release.metallb
  ]
  wait      = true
  force_new = true
  yaml_body = templatefile("./files/metallb/advertisement.yaml", {
    namespace     = kubernetes_namespace.metallb.metadata[0].name
    address-range = var.metallb_addr_range
  })
}
