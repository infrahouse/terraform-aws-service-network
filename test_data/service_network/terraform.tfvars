
region                = "us-east-1"
management_cidr_block = "10.1.0.0/16"
vpc_cidr_block        = "10.1.0.0/16"
subnets = [
  {
    cidr                    = "10.1.0.0/24"
    availability-zone       = "us-east-1a"
    map_public_ip_on_launch = true
    create_nat              = true
    forward_to              = null
  },
  {
    cidr                    = "10.1.1.0/24"
    availability-zone       = "us-east-1b"
    map_public_ip_on_launch = false
    create_nat              = false
    forward_to              = "10.1.0.0/24"
  },
  {
    cidr                    = "10.1.2.0/24"
    availability-zone       = "us-east-1c"
    map_public_ip_on_launch = false
    create_nat              = false
    forward_to              = "10.1.0.0/24"
  }
]
            