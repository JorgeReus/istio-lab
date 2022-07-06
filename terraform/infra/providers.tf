terraform {
  required_providers {
    kubernetes = "~> 2.10.0"
    helm       = "~> 2.5.1"
  }
  required_version = "~> 1.0.0"
}

# We use K3d so this is good enough
provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

