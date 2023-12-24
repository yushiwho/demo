locals {
  azs             = data.aws_availability_zones.available.zone_ids
  main_cidr_block = "10.0.0.0/16"
  private_subnets = [
    for idx, _ in local.azs :
    format("10.%d.0.0/16", idx + 1)
  ]
  public_subnets = [
    for idx, _ in local.azs :
    format("10.0.%d.0/24", idx + 1)
  ]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name                  = local.name_prefix
  cidr                  = "10.0.0.0/16"
  secondary_cidr_blocks = local.private_subnets

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}
