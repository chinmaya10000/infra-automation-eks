provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }  
}

# EKS Blueprint Add-ons
module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.22.0"  #ensure to update this to the latest/desired version
  
  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = { most_recent = true }
    coredns            = { most_recent = true }
    vpc-cni            = { most_recent = true }
    kube-proxy         = { most_recent = true }
  }

#   enable_aws_load_balancer_controller    = true
  enable_metrics_server                  = true
  enable_cert_manager                    = true
  cert_manager = {
    most_recent = true
    namespace   = "cert-manager"
  }

  # NGINX INGRESS CONTROLLER
  enable_ingress_nginx = true
  ingress_nginx = {
    most_recent = true
    namespace   = "ingress-nginx"

    set = [
        { name = "controller.service.type", value = "LoadBalancer" },
        { name = "controller.service.externalTrafficPolicy", value = "Local" },
        { name = "controller.resources.requests.cpu", value = "100m" },
        { name = "controller.resources.requests.memory", value = "128Mi" },
        { name = "controller.resources.limits.cpu", value = "200m" },
        { name = "controller.resources.limits.memory", value = "256Mi" }
    ]
    set_sensitive = [
        { name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme", value = "internet-facing" },
        { name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type", value = "nlb-ip" },
        { name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-nlb-target-type", value = "ip" },
        { name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-health-check-path", value = "/healthz" },
        { name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-health-check-port", value = "10254" },
        { name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-health-check-protocol", value = "HTTP" }
    ]
  }

  depends_on = [ module.eks ]
}
