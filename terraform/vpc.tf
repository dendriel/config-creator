resource "aws_vpc" "main" {
  cidr_block           = var.vpc.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name      = "config-creator-vpc"
    env       = "prod"
    terraform = "true"
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = aws_vpc.main.id
  tags = { Tier = "private" }
}

data "aws_subnet_ids" "public" {
  vpc_id = aws_vpc.main.id
  tags = { Tier = "public" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name      = "config-creator-igw"
    env       = "prod"
    terraform = "true"
  }
}

resource "aws_route" "aws_route_public_to_igw" {
    destination_cidr_block = "0.0.0.0/0"
    route_table_id         = aws_route_table.rtb_public.id
    gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_subnet" "subnet_public0" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc.public_subnets_cidr[0]
  map_public_ip_on_launch = true
  availability_zone       = var.vpc.azs[0]
  assign_ipv6_address_on_creation = false

  tags = {
    Name      = "config-creator-vpc-subnet-public0"
    env       = "prod"
    terraform = "true"
    Tier      = "public"
  }
}

resource "aws_subnet" "subnet_public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc.public_subnets_cidr[1]
  map_public_ip_on_launch = true
  availability_zone       = var.vpc.azs[1] # TODO: launch on sa-east-1c
  assign_ipv6_address_on_creation = false

  tags = {
    Name      = "config-creator-vpc-subnet-public1"
    env       = "prod"
    terraform = "true"
    Tier      = "public"
  }
}

resource "aws_subnet" "subnet_private0" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc.private_subnets_cidr[0]
  map_public_ip_on_launch = false
  availability_zone       = var.vpc.azs[0]
  assign_ipv6_address_on_creation = false

  tags = {
    Name      = "config-creator-vpc-subnet-private0"
    env       = "prod"
    terraform = "true"
    Tier      = "private"
  }
}

resource "aws_subnet" "subnet_private1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc.private_subnets_cidr[1]
  map_public_ip_on_launch = false
  availability_zone       = var.vpc.azs[1]
  assign_ipv6_address_on_creation = false

  tags = {
    Name      = "config-creator-vpc-subnet-private1"
    env       = "prod"
    terraform = "true"
    Tier      = "private"
  }
}

# module "vpc" {
#   source = "terraform-aws-modules/vpc/aws"

#   name            = "config-creator-vpc"
#   azs             = var.vpc.azs
#   cidr            = var.vpc.cidr
#   public_subnets  = var.vpc.public_subnets_cidr
#   private_subnets  = var.vpc.private_subnets_cidr

#   tags = {
#     env = "prod"
#     terraform = "true"
#   }
# }

# data "aws_vpc" "main" {
#   id = module.vpc.vpc_id
# }