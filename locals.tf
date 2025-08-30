# Get AZs dynamically
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  # Subnet sizing: /19 per subnet (sufficient for most clusters)
  private_subnet_cidr_blocks = [ for idx, az in local.azs : cidrsubnet(var.vpc_cidr_block, 4, idx + 10) ]
  public_subnet_cidr_blocks = [ for idx, az in local.azs : cidrsubnet(var.vpc_cidr_block, 4, idx) ]

  # Environment-specific tags
  environment_tags = merge(
    var.tags,
    {
        App = "${var.env}-eks"
        Environment = var.env
        Name = "${var.name}-${var.env}"
    }
  )

  public_subnet_tags = merge(
    local.environment_tags,
    {
        "kubernetes.io/role/elb" = "1"
        "kubernetes.io/cluster/${var.name}-${var.env}" = "shared"
    }
  )

  private_subnet_tags = merge(
    local.environment_tags,
    {
        "kubernetes.io/role/internal-elb" = "1"
        "kubernetes.io/cluster/${var.name}-${var.env}" = "shared"
    }
  )
}