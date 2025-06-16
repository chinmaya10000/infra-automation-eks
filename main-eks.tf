provider "aws" {
    region = var.aws_region
}

# VPC configuration
data "aws_availability_zones" "azs" {}

module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "5.20.0"

    name = var.name
    cidr = var.vpc_cidr_block

    azs = data.aws_availability_zones.azs.names
    private_subnets = var.private_subnet_cidr_blocks
    public_subnets = var.public_subnet_cidr_blocks

    enable_nat_gateway = true
    single_nat_gateway = true

    public_subnet_tags = {
        "kubernetes.io/role/elb" = "1"
    }
    private_subnet_tags = {
        "kubernetes.io/role/internal-elb" = "1"
    }

    tags = var.tags
}

# EKS cluster configuration
module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "~> 19.0"

    cluster_name = var.name
    cluster_version = var.k8s_version

    cluster_endpoint_public_access = true

    vpc_id = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets

    create_node_security_group = false
    create_cluster_security_group = false

    manage_aws_auth_configmap = true
    aws_auth_roles = local.aws_k8s_role_mapping
    
    cluster_addons = {
        kube-proxy = {}
        vpc-cni = {}
        coredns = {}
    }

    eks_managed_node_groups = {
        initial = {
            instance_type = ["t2.medium"]
            min_size = 2
            max_size = 7
            desired_size = 3
        }
    }

    tags = var.tags
}