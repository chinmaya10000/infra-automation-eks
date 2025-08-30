module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"

  name = "${var.name}-${var.env}-vpc"
  cidr = var.vpc_cidr_block

  azs = local.azs
  private_subnets = local.private_subnet_cidr_blocks
  public_subnets = local.public_subnet_cidr_blocks

  create_igw = true
  enable_nat_gateway = true
  single_nat_gateway = var.single_nat_gateway

  enable_dns_hostnames = true
  enable_dns_support = true

  manage_default_network_acl = true
  default_network_acl_tags = merge(local.environment_tags, {Name = "${var.name}-default-nacl"})
  manage_default_route_table = true
  default_route_table_tags = merge(local.environment_tags, {Name = "${var.name}-default-rt"})
  manage_default_security_group = true
  default_security_group_tags = merge(local.environment_tags, {Name = "${var.name}-default-sg"})

  public_subnet_tags = local.public_subnet_tags
  private_subnet_tags = local.private_subnet_tags

  tags = local.environment_tags
}