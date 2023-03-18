region = "us-east-1"

domain_name = "philemonnwanne.me"

vpc_name = "capstone_vpc"

cidr = "10.0.0.0/16"

azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

public_subnets = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]

public_subnets_names = ["capstone-subnet-public1-us-east-1a", "capstone-subnet-public2-us-east-1b","capstone-subnet-public2-us-east-1c"]

private_subnets = ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20"]


private_subnets_names = ["capstone-subnet-private1-us-east-1a", "capstone-subnet-private2-us-east-1b", "capstone-subnet-private2-us-east-1c"]

instance_type = "t2.medium"