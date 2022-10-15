# resource "kubernetes_manifest" "authorizationpolicy_productpage_viewer" {
#   manifest = {
#     apiVersion = "security.istio.io/v1beta1"
#     kind       = "AuthorizationPolicy"
#     metadata = {
#       name      = "productpage-viewer"
#       namespace = var.app_namespace
#     }
#     spec = {
#       action = "ALLOW"
#       rules = [
#         {
#           from = [
#             {
#               source = {
#                 principals = [
#                   # Allow the sleep service identified by the service account to readh the product page
#                   "cluster.local/ns/${var.app_namespace}/sa/${kubernetes_manifest.sa_sleep.manifest.metadata.name}",
#                   # Allow the ingress gateway identified by the service account to reach the product page
#                   "cluster.local/ns/istio-system/sa/${var.ingressgateway-name}-service-account",
#                 ]
#               }
#             }
#           ]
#           to = [
#             {
#               operation = {
#                 methods = ["GET"]
#               }
#             }
#           ]
#         }
#       ]
#       selector = {
#         matchLabels = {
#           app = var.productpage_name
#         }
#       }
#     }
#   }
# }
