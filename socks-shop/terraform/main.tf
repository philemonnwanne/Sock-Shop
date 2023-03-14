provider "aws" {
  region = var.region
}

locals {
  cluster_name = "capstone"
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.18.1"

  name                 = var.vpc_name
  cidr                 = var.cidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  private_subnet_names = var.private_subnets_names
  public_subnet_names  = var.public_subnets_names
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.10.0"

  cluster_name                   = local.cluster_name
  cluster_version                = "1.24"
  cluster_endpoint_public_access = true
  # cluster_endpoint_private_access = true

  subnet_ids = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  eks_managed_node_groups = {
    node_01 = {
      name         = "${local.cluster_name}-node-group-1"
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_type = var.instance_type
    }

    node_02 = {
      name         = "${local.cluster_name}-node-group-2"
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_type = var.instance_type
    }

  }
  tags = {
    Name        = "${local.cluster_name}-project-eks-cluster"
    Environment = "production"
    Maintainer  = "philemon nwanne"
  }
}
