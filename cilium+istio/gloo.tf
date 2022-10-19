resource "kubernetes_namespace" "gloo" {
  metadata {
    name = "gloo-system"
  }
}

resource "helm_release" "gloo" {
  name            = "gloo"
  namespace       = kubernetes_namespace.gloo.metadata[0].name
  repository      = "https://storage.googleapis.com/solo-public-helm"
  chart           = "gloo"
  cleanup_on_fail = true
  values = [file("./files/gloo.yml")]
}
