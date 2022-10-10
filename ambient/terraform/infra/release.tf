resource "null_resource" "get_istio_release" {
  triggers = {
    exists = fileexists("./istio-${var.istio_version}/manifest.yaml")
  }
  provisioner "local-exec" {
    command = "curl -o - ${local.istio_release_url} | tar -xz"
  }
}
