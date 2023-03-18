provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

locals {
  cluster_name = "capstone"
  oidc_url = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  account_id = data.aws_caller_identity.current.account_id
}

# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.cluster.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#   token                  = data.aws_eks_cluster_auth.cluster.token
# }

module "eks-kubeconfig" {
  source  = "hyperbadger/eks-kubeconfig/aws"
  version = "1.0.0"

  depends_on = [module.eks]
  cluster_id = module.eks.cluster_name
}

resource "local_file" "kubeconfig" {
  content  = module.eks-kubeconfig.kubeconfig
  filename = "kubeconfig_${local.cluster_name}"
}

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
  cluster_endpoint_private_access = true

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

resource "aws_iam_policy" "worker_policy" {
  name        = "worker-policy"
  description = "Worker policy for the ALB Ingress"

  policy = file("${path.module}/iam-policy.json")
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = module.eks.eks_managed_node_groups

  policy_arn = aws_iam_policy.worker_policy.arn
  role       = each.value.iam_role_name

}

# module "lb_role" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

#   role_name                              = "prod_eks_lb"
#   attach_load_balancer_controller_policy = true

#   oidc_providers = {
#     main = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
#     }
#   }
# }

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1"
    args        = ["eks", "get-token", "--cluster-name", local.cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1"
      args        = ["eks", "get-token", "--cluster-name", local.cluster_name]
      command     = "aws"
    }
  }
}

# resource "kubernetes_service_account" "service-account" {
#   metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "kube-system"
#     labels = {
#       "app.kubernetes.io/name"      = "aws-load-balancer-controller"
#       "app.kubernetes.io/component" = "controller"
#     }
#     annotations = {
#       "eks.amazonaws.com/role-arn"               = module.lb_role.iam_role_arn
#       "eks.amazonaws.com/sts-regional-endpoints" = "true"
#     }
#   }
# }

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

# resource "aws_iam_role" "external_dns" {
#   name  = "${module.eks.cluster_name}-external-dns"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Federated": "arn:aws:iam::${local.account_id}:oidc-provider/${local.oidc_url}"
#       },
#       "Action": "sts:AssumeRoleWithWebIdentity",
#       "Condition": {
#         "StringEquals": {
#           "${local.oidc_url}:sub": "system:serviceaccount:kube-system:external-dns"
#         }
#       }
#     }
#   ]
# }
# EOF

# }

# resource "aws_iam_role_policy" "external_dns" {
#   name_prefix = "${module.eks.cluster_id}-external-dns"
#   role        = aws_iam_role.external_dns.name
#   policy      = file("${path.module}/json/external-dns-iam-policy.json")
# }

# resource "kubernetes_service_account" "external_dns" {
#   metadata {
#     name      = "external-dns"
#     namespace = "kube-system"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns.arn
#     }
#   }
#   automount_service_account_token = true
# }

# resource "kubernetes_cluster_role" "external_dns" {
#   metadata {
#     name = "external-dns"
#   }

#   rule {
#     api_groups = [""]
#     resources  = ["services", "pods", "nodes"]
#     verbs      = ["get", "list", "watch"]
#   }
#   rule {
#     api_groups = ["extensions", "networking.k8s.io"]
#     resources  = ["ingresses"]
#     verbs      = ["get", "list", "watch"]
#   }
#   rule {
#     api_groups = ["networking.istio.io"]
#     resources  = ["gateways"]
#     verbs      = ["get", "list", "watch"]
#   }
# }

# resource "kubernetes_cluster_role_binding" "external_dns" {
#   metadata {
#     name = "external-dns"
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = kubernetes_cluster_role.external_dns.metadata.0.name
#   }
#   subject {
#     kind      = "ServiceAccount"
#     name      = kubernetes_service_account.external_dns.metadata.0.name
#     namespace = kubernetes_service_account.external_dns.metadata.0.namespace
#   }
# }

# resource "helm_release" "external_dns" {
#   name       = "external-dns"
#   namespace  = kubernetes_service_account.external_dns.metadata.0.namespace
#   wait       = true
#   repository = "https://charts.bitnami.com/bitnami"
#   chart      = "external-dns"
#   version    = var.external_dns_chart_version

#   set {
#     name  = "rbac.create"
#     value = false
#   }

#   set {
#     name  = "serviceAccount.create"
#     value = false
#   }

#   set {
#     name  = "serviceAccount.name"
#     value = kubernetes_service_account.external_dns.metadata.0.name
#   }

#   set {
#     name  = "rbac.pspEnabled"
#     value = false
#   }

#   set {
#     name  = "name"
#     value = "${local.cluster_name}-external-dns"
#   }

#   set {
#     name  = "provider"
#     value = "aws"
#   }

#   set_string {
#     name  = "policy"
#     value = "sync"
#   }

#   set_string {
#     name  = "logLevel"
#     value = var.external_dns_chart_log_level
#   }

#   set {
#     name  = "sources"
#     value = "{ingress,service}"
#   }

#   set {
#     name  = "domainFilters"
#     value = "{${join(",", var.external_dns_domain_filters)}}"
#   }

#   set_string {
#     name  = "aws.zoneType"
#     value = var.external_dns_zoneType
#   }

#   set_string {
#     name  = "aws.region"
#     value = var.aws_region
#   }
# }

# module "eks_blueprints_kubernetes_addons" {
#   source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons"

#   cluster_id                    = eks_cluster_id

#   # EKS Addons
#   #K8s Add-ons
#   # enable_aws_load_balancer_controller  = true
#   enable_external_dns = true
#   enable_kube_prometheus_stack      = true
#   # enable_vault = true
# }

# kube_prometheus_stack_helm_config = {
#   set = [
#     {
#       name  = "kubeProxy.enabled"
#       value = false
#     }
#   ],
#   set_sensitive = [
#     {
#       name  = "grafana.adminPassword"
#       value = data.aws_secretsmanager_secret_version.admin_password_version.secret_string
#     }
#   ]
# }