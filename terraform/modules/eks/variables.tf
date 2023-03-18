variable "subnet_ids" {
  description = "VPC subnet to launch cluster node"
  type        = list(string)
}

variable "vpc_id" {
  description = "project VPC id"
  type        = string
}

variable "cluster_name" {
  description = "project cluster name"
  type        = string
  default = "capstone"
}

variable "instance_type" {
  description = "the size of the instance to be deployed"
  type        = string
  default     = "t2.medium"
}

variable "tags" {
  description = "tags to apply to resources created by EKS module"
  type        = map(string)
}