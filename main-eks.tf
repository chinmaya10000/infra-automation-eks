module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name = "${var.name}-${var.env}"
  kubernetes_version = var.k8s_version

  # Optional
  endpoint_public_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  # Automode compute config
  compute_config = {
    enabled    = true
    node_pools = ["general-purpose"] # AWS handles scaling automatically
  }

  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  create_kms_key = true
  kms_key_description = "KMS key for EKS cluster ${var.name}-${var.env}"
  kms_key_deletion_window_in_days = 7

  tags = local.environment_tags

  addons = {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  depends_on = [ module.vpc ]
}

