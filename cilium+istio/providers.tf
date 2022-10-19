terraform {
  required_providers {
    kubernetes = "~> 2.10.0"
    helm       = "~> 2.7.1"
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
  required_version = "~> 1.0.0"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "kubectl" {

}
