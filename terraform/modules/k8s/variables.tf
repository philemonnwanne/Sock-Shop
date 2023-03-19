variable "cluster_name" {
  description = "cluster name"
  type        = string
  default = "capstone"
}


variable "cluster_ca_certificate" {
  description = "cluster name"
  type        = string
}

variable "host" {
  description = "cluster name"
  type        = string
}

# host  = data.aws_eks_cluster.cluster.endpoint
# cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)