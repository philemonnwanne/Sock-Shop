# retrieve info about the vpc created above
data "aws_availability_zones" "available" {}

# create a vpc
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
  map_public_ip_on_launch = true
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}