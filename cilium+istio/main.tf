resource "helm_release" "cilium" {
  name            = "cilium"
  namespace       = "kube-system"
  repository      = "https://helm.cilium.io/"
  chart           = "cilium"
  version         = "1.12.3"
  cleanup_on_fail = true
  values = [templatefile("./files/cilium.yml",
    {
      k8s-svc-host : var.k8s-svc-host
    }
  )]
}
