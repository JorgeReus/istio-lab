provider "kubernetes" {
  config_path = "~/.kube/config"
}

terraform {
  required_providers {
    kubernetes = "~> 2.10.0"
  }
  required_version = "~> 1.0.0"
}
