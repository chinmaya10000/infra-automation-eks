terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.3.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.37.1"
    }
    helm = {
      source = "hashicorp/helm"
      version = "3.0.2"
    }
  }
}
