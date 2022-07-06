variable "namespace_name" {
  default = "istio-test"
}

variable "gateway-name" {
  default = "istio-gateway-default"
}

# variable "registry_name" {
#   default = "istio-test-registry"
# }
# variable "app-name" {
#   default = "mock-app"
# }
#
#
# variable "max_timeout" {
#   default = "30s"
# }
#
# variable "retry_config" {
#   default = {
#     attempts = 10
#     perTryTimeout = "2s"
#     retryOn = "5xx"
#   }
# }
