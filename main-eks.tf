provider "aws" {
    region = var.aws_region
}

provider "helm" {
  kubernetes {
    host = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command = "aws"
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
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

module "eks_blueprints_addons" {
    source = "aws-ia/eks-blueprints-addons/aws"
    version = "~> 1.0" #ensure to update this to the latest/desired version

    cluster_name      = module.eks.cluster_name
    cluster_endpoint  = module.eks.cluster_endpoint
    cluster_version   = module.eks.cluster_version
    oidc_provider_arn = module.eks.oidc_provider_arn

    eks_addons = {
        aws-ebs-csi-driver = {
            most_recent = true
        }
    }

    enable_aws_load_balancer_controller    = true
    enable_metrics_server                  = true
    enable_cluster_autoscaler              = true
    cluster_autoscaler = {
        set = [
            {
                name = "extraArgs.scale-down-unneeded-time"
                value = "1m"
            },
            {
                name = "extraArgs.skip-nodes-with-local-storage"
                value = "false"
            },
            {
                name = "extraArgs.skip-nodes-with-system-pods"
                value = "false"
            }
        ]
    }
}