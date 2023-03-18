# this module creates an eks cluster on aws
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.10.0"

  cluster_name                   = var.cluster_name
  cluster_version                = "1.24"
  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true
  subnet_ids = var.subnet_ids
  vpc_id = var.vpc_id

  eks_managed_node_groups = {
    node_01 = {
      name         = "${var.cluster_name}-node-group-1"
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_type = var.instance_type
    }

    node_02 = {
      name         = "${var.cluster_name}-node-group-2"
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_type = var.instance_type
    }

  }
  tags = var.tags
}