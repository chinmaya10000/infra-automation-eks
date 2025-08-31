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

  # NAT / Public Route Tables
  public_route_table_tags  = local.public_route_table_tags
  private_route_table_tags = local.private_route_table_tags
  
  # Default route table
  manage_default_route_table = true
  default_route_table_tags = local.default_route_table_tags
  
  # Default NACL and SG
  manage_default_network_acl = true
  default_network_acl_tags = local.default_network_acl_tags
  manage_default_security_group = true
  default_security_group_tags = local.default_security_group_tags
  
  # Subnet tags
  public_subnet_tags = local.public_subnet_tags
  private_subnet_tags = local.private_subnet_tags

  tags = local.environment_tags
}