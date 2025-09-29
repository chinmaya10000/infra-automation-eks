# Get AZs dynamically
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# Random suffix for unique resource names
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

locals {
  # Cluster configuration with unique suffix to avoid conflicts
  cluster_name = "${var.cluster_name}-${random_string.suffix.result}"

  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  # Subnet sizing: /19 per subnet (sufficient for most clusters)
  private_subnet_cidr_blocks = [for idx, az in local.azs : cidrsubnet(var.vpc_cidr_block, 4, idx + 10)]
  public_subnet_cidr_blocks  = [for idx, az in local.azs : cidrsubnet(var.vpc_cidr_block, 4, idx)]

  # Common tags applied to all resources
  common_tags = {
    Environment   = var.env
    Project       = "retail-store"
    ManagedBy     = "terraform"
    CreatedBy     = "Chinmaya"
    Owner         = data.aws_caller_identity.current.user_id
    CreatedDate   = formatdate("YYYY-MM-DD", timestamp())
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"             = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}