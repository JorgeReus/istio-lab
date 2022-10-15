# resource "kubernetes_manifest" "virtualservice_reviews" {
#   manifest = {
#     apiVersion = "networking.istio.io/v1alpha3"
#     kind       = "VirtualService"
#     metadata = {
#       name      = var.reviews_name
#       namespace = var.app_namespace
#     }
#     spec = {
#       hosts = [
#         var.reviews_name
#       ]
#       http = [
#         {
#           route = [
#             {
#               destination = {
#                 host   = var.reviews_name
#                 subset = "v1"
#               }
#               weight = 90
#             },
#             {
#               destination = {
#                 host   = var.reviews_name
#                 subset = "v2"
#               }
#               weight = 10
#             }
#           ]
#         }
#       ]
#     }
#   }
# }
#
# resource "kubernetes_manifest" "destinationrule_reviews" {
#   manifest = {
#     apiVersion = "networking.istio.io/v1alpha3"
#     kind       = "DestinationRule"
#     metadata = {
#       name      = var.reviews_name
#       namespace = var.app_namespace
#     }
#     spec = {
#       host = var.reviews_name
#       subsets = [
#         {
#           labels = {
#             version = "v1"
#           }
#           name = "v1"
#         },
#         {
#           labels = {
#             version = "v2"
#           }
#           name = "v2"
#         },
#         {
#           labels = {
#             version = "v3"
#           }
#           name = "v3"
#         },
#       ]
#       trafficPolicy = {
#         loadBalancer = {
#           simple = "RANDOM"
#         }
#       }
#     }
#   }
# }
