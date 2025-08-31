provider "aws" {
  region = var.aws_region
}

terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 6.9.0, < 7.0.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.35.0, < 3.0.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.17.0"
    }
    time = {
      source = "hashicorp/time"
      version = "0.13.1"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.4"
    }
  }
}
