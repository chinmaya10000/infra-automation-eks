# Get AZs dynamically
data "aws_availability_zones" "available" {
  state = "available"
}

# Get current region dynamically
data "aws_region" "current" {}

locals {
  region = data.aws_region.current.id  # fixes deprecated .name warning
  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  # Subnet sizing: /19 per subnet (sufficient for most clusters)
  private_subnet_cidr_blocks = [for idx, az in local.azs : cidrsubnet(var.vpc_cidr_block, 4, idx + 10)]
  public_subnet_cidr_blocks  = [for idx, az in local.azs : cidrsubnet(var.vpc_cidr_block, 4, idx)]

  # Environment-specific tags
  environment_tags = merge(
    var.tags,
    {
      App         = "${var.env}-eks"
      Environment = var.env
      Name        = "${var.name}-${var.env}"
    }
  )

  public_subnet_tags = merge(
    local.environment_tags,
    {
      Name                                           = "${var.name}-${var.env}-public-subnet"
      Type                                           = "public"
      "kubernetes.io/role/elb"                       = "1"
      "kubernetes.io/cluster/${var.name}-${var.env}" = "shared"
    }
  )

  private_subnet_tags = merge(
    local.environment_tags,
    {
      Name                                           = "${var.name}-${var.env}-private-subnet"
      Type                                           = "private"
      "kubernetes.io/role/internal-elb"              = "1"
      "kubernetes.io/cluster/${var.name}-${var.env}" = "shared"
    }
  )

  # Default route table tags
  default_route_table_tags = merge(
    local.environment_tags,
    {
      Name = "${var.name}-${var.env}-default-rt"
      Type = "default"
    }
  )

  # NAT / public route tables
  public_route_table_tags = merge(
    local.environment_tags,
    {
      Name = "${var.name}-${var.env}-public-rt"
      Type = "public"
    }
  )

  private_route_table_tags = merge(
    local.environment_tags,
    {
      Name = "${var.name}-${var.env}-private-rt"
      Type = "private"
    }
  )

  # Default NACL / Security Group tags
  default_network_acl_tags = merge(
    local.environment_tags,
    {
      Name = "${var.name}-${var.env}-default-nacl"
      Type = "default"
    }
  )

  default_security_group_tags = merge(
    local.environment_tags,
    {
      Name = "${var.name}-${var.env}-default-sg"
      Type = "default"
    }
  )
}