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
    attempts = 10
    perTryTimeout = "15s"
    retryOn = "5xx"
  }
}
