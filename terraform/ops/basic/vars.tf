variable "app-name" {
  default = "mock-app"
}

variable "namespace_name" {
  default = "istio-test"
}

variable "gateway-name" {
  default = "istio-gateway-default"
}

variable "retry_config" {
  default = {
    attempts      = 15
    perTryTimeout = "10s"
    retryOn       = "5xx"
  }
}
