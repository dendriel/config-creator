module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name            = "config-creator-vpc"
  azs             = var.vpc.azs
  cidr            = var.vpc.cidr
  public_subnets  = var.vpc.public_subnets_cidr

  tags = {
    env = "prod"
    terraform = "true"
  }
}

data "aws_vpc" "main" {
  id = module.vpc.vpc_id
}