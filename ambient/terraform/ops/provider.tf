terraform {
  required_providers {
    kubernetes = "~> 2.10.0"
  }
  required_version = "~> 1.0.0"
}

# We use kind, so this is good enough
provider "kubernetes" {
  config_path = "~/.kube/config"
}
