variable "aws_region" {
  description = "The AWS region where the resources will be created."
  type        = string
  default     = "us-east-2"
}

variable "env" {
  description = "The environment for the deployment (e.g., dev, staging, prod)."
  type        = string
  default     = "staging"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_name" {
  description = "The name prefix for all resources."
  type        = string
  default     = "retail-store"
}

variable "k8s_version" {
  description = "The Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.33"
}

# NAT gateway HA option
variable "single_nat_gateway" {
  description = "Set true for dev/stage, false for prod (one NAT per AZ)"
  type        = bool
  default     = true
}