variable "vpc_name" {
  description = "Name of VPC"
  type        = string
  default     = "capstone"
}

variable "cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_name" {
  description = "project cluster name"
  type        = string
  default = "capstone"
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

variable "tags" {
  description = "tags to apply to resources created by VPC module"
  type        = map(string)
}