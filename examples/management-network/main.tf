data "aws_availability_zones" "available" {
  state = "available"
}

module "management" {
  source  = "registry.infrahouse.com/infrahouse/service-network/aws"
  version = "4.0.0"

  environment           = "production"
  service_name          = "management"
  vpc_cidr_block        = "10.1.0.0/16"
  management_cidr_block = "10.1.0.0/16"
  restrict_all_traffic  = true
  enable_dns_hostnames  = true
  enable_dns_support    = true
  enable_vpc_flow_logs  = true
  subnets = [
    {
      cidr                    = "10.1.0.0/24"
      availability_zone       = data.aws_availability_zones.available.names[0]
      map_public_ip_on_launch = true
      create_nat              = true
    },
    {
      cidr              = "10.1.1.0/24"
      availability_zone = data.aws_availability_zones.available.names[1]
      forward_to        = "10.1.0.0/24"
    },
    {
      cidr                    = "10.1.2.0/24"
      availability_zone       = data.aws_availability_zones.available.names[0]
      map_public_ip_on_launch = false
      forward_to              = "10.1.0.0/24"
    },
    {
      cidr                    = "10.1.3.0/24"
      availability_zone       = data.aws_availability_zones.available.names[1]
      map_public_ip_on_launch = true
      create_nat              = true
    },
  ]
}

output "vpc_id" {
  description = "The management VPC ID"
  value       = module.management.vpc_id
}

output "subnet_public_ids" {
  description = "Public subnet IDs"
  value       = module.management.subnet_public_ids
}

output "subnet_private_ids" {
  description = "Private subnet IDs"
  value       = module.management.subnet_private_ids
}
