# Examples

Working, deployable examples live in the
[examples/](https://github.com/infrahouse/terraform-aws-service-network/tree/main/examples)
directory of the repository. This page walks through the common use cases.

## Management Network (the Hub)

The management network must exist before any service network. A network is a management
network when `management_cidr_block` equals `vpc_cidr_block`:

```hcl
data "aws_availability_zones" "available" {
  state = "available"
}

module "management" {
  source  = "registry.infrahouse.com/infrahouse/service-network/aws"
  version = "5.0.1"

  environment           = "production"
  service_name          = "management"
  vpc_cidr_block        = "10.1.0.0/16"
  management_cidr_block = "10.1.0.0/16"
  replication_region    = "us-east-1"
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
    }
  ]
}
```

## Service Network (a Spoke)

A service network uses its own `vpc_cidr_block` and points `management_cidr_block` at the
hub. The module creates the VPC peering connection and routes on both sides automatically:

```hcl
module "website" {
  source  = "registry.infrahouse.com/infrahouse/service-network/aws"
  version = "5.0.1"

  environment           = "production"
  service_name          = "website"
  vpc_cidr_block        = "10.2.0.0/16"
  management_cidr_block = "10.1.0.0/16" # the hub's CIDR
  replication_region    = "us-east-1"
  subnets = [
    {
      cidr                    = "10.2.0.0/24"
      availability_zone       = data.aws_availability_zones.available.names[0]
      map_public_ip_on_launch = true
      create_nat              = true
    },
    {
      cidr              = "10.2.1.0/24"
      availability_zone = data.aws_availability_zones.available.names[1]
      forward_to        = "10.2.0.0/24"
    }
  ]
}
```

## Standalone Network

For a single VPC with no peering at all, declare it as its own management network
(`management_cidr_block = vpc_cidr_block`). No peering resources are created.

## High-Availability NAT (one per AZ)

A single NAT Gateway is a single point of failure and incurs cross-AZ data charges. For
production workloads, create one NAT per availability zone and forward each private
subnet to the NAT in its own AZ:

```hcl
subnets = [
  # Public subnets, one NAT each
  {
    cidr                    = "10.2.0.0/24"
    availability_zone       = "us-west-2a"
    map_public_ip_on_launch = true
    create_nat              = true
  },
  {
    cidr                    = "10.2.1.0/24"
    availability_zone       = "us-west-2b"
    map_public_ip_on_launch = true
    create_nat              = true
  },
  # Private subnets, each using the NAT in the same AZ
  {
    cidr              = "10.2.10.0/24"
    availability_zone = "us-west-2a"
    forward_to        = "10.2.0.0/24"
  },
  {
    cidr              = "10.2.11.0/24"
    availability_zone = "us-west-2b"
    forward_to        = "10.2.1.0/24"
  }
]
```

## Fully Isolated Subnets

A subnet with neither `map_public_ip_on_launch`, `create_nat`, nor `forward_to` has no
route to the internet — only VPC-internal and management peering traffic. Useful for
databases:

```hcl
subnets = [
  {
    cidr              = "10.2.20.0/24"
    availability_zone = "us-west-2a"
  }
]
```

## Custom Tags

Tags can be applied module-wide and per subnet:

```hcl
module "website" {
  # ...

  tags = {
    team = "platform"
  }

  subnets = [
    {
      cidr              = "10.2.0.0/24"
      availability_zone = "us-west-2a"
      tags = {
        tier = "frontend"
      }
    }
  ]
}
```
