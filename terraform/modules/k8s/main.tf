# create local variables
locals {
  cluster_name = var.cluster_name
}

# retrieve info about the eks-cluster created on AWS
# data "aws_eks_cluster" "cluster" {
#   name = local.cluster_name
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = local.cluster_name
# }

# # this block configures the Kubernetes provider
provider "kubernetes" {
  host                   = var.host
  cluster_ca_certificate = var.cluster_ca_certificate
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      data.aws_eks_cluster.cluster.name
    ]
  }
}

# # this block configures the Helm provider
provider "helm" {
  kubernetes {
    host                   = var.host
    cluster_ca_certificate = var.cluster_ca_certificate
    exec {
      api_version = "client.authentication.k8s.io/v1"
      args        = ["eks", "get-token", "--cluster-name", local.cluster_name]
      command     = "aws"
    }
  }
}

# create an ALB ingress controller
resource "helm_release" "ingress" {
  name       = "ingress"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.4.6"

  set {
    name  = "autoDiscoverAwsRegion"
    value = "true"
  }
  set {
    name  = "autoDiscoverAwsVpcID"
    value = "true"
  }

  set {
    name  = "clusterName"
    value = local.cluster_name
  }
}