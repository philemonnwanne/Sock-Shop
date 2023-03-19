output "capstone_vpc_id" {
    description = "project VPC ID"
    value = module.vpc.vpc_id
}

output "capstone_vpc_name" {
    description = "project VPC name"
    value = module.vpc.name
}

output "capstone_vpc_public_subnets" {
    description = "project VPC subnet ID"
    value = module.vpc.public_subnets
}

output "capstone_vpc_private_subnets" {
    description = "project VPC subnet ID"
    value = module.vpc.private_subnets
}

output "capstone_vpc_security_group_id" {
    description = "project VPC default security group ID"
    value = module.vpc.default_security_group_id
}

output "azs" {
    description = "AZ to start the instance in"
    value = module.vpc.azs
}