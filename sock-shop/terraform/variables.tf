variable "region" {
  description = "region to deploy all project resources"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "domain name to attach"
  type        = string
  default     = "philemonnwanne.me"
}

variable "vpc_name" {
  description = "Name of VPC"
  type        = string
  default     = "capstone_vpc"
}

variable "cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "availability zones for VPC"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnets" {
  description = "public subnets for VPC"
  type        = list(string)
  default     = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
}

variable "public_subnets_names" {
  description = "private subnet names for VPC"
  type        = list(string)
  default     = ["capstone-subnet-public1-us-east-1a", "capstone-subnet-public2-us-east-1b","capstone-subnet-public2-us-east-1c"]
}

variable "private_subnets" {
  description = "private subnets for VPC"
  type        = list(string)
  default     = ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20"]
}

variable "private_subnets_names" {
  description = "private subnet names for VPC"
  type        = list(string)
  default     = ["capstone-subnet-private1-us-east-1a", "capstone-subnet-private2-us-east-1b", "capstone-subnet-private2-us-east-1c"]
}

variable "instance_type" {
  description = "the size of the instance to be deployed"
  type        = string
  default     = "t2.medium"
}

variable "external_dns_chart_version" {
  description = "External-dns Helm chart version to deploy. 3.0.0 is the minimum version for this function"
  type        = string
  default     = "3.0.0"
}

variable "external_dns_chart_log_level" {
  description = "External-dns Helm chart log leve. Possible values are: panic, debug, info, warn, error, fatal"
  type        = string
  default     = "warn"
}

# variable "external_dns_zoneType" {
#   description = "External-dns Helm chart AWS DNS zone type (public, private or empty for both)"
#   type        = string
#   default     = ""
# }

# variable "external_dns_domain_filters" {
#   description = "External-dns Domain filters."
#   type        = list(string)
# }