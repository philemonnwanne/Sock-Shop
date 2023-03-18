variable "region" {
  description = "region to deploy all project resources"
  type        = string
}

variable "domain_name" {
  description = "domain name to attach"
  type        = string
}

variable "cluster_name" {
  description = "cluster name"
  type        = string
}

variable "vpc_name" {
  description = "Name of VPC"
  type        = string
}

variable "maintainer" {
  description = "project maintainer"
  type        = string
}

variable "track" {
  description = "career track"
  type        = string
}