variable "cluster_name" {
  description = "cluster name"
  type        = string
  default = "capstone"
}

variable "oidc_url" {
  description = "cluster name"
  type        = string
  default = ""
}

variable "aws_region" {
  description = "The AWS region to deploy to (e.g. us-east-1)"
  type = string
  default = "us-east-1"
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

variable "external_dns_zoneType" {
  description = "External-dns Helm chart AWS DNS zone type (public, private or empty for both)"
  type        = string
  default     = "public"
}
