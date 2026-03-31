# Getting Started

## Prerequisites

- Terraform >= 1.0
- AWS provider >= 5.11, < 7.0
- An AWS account with permissions to create VPCs, subnets, route tables,
  internet gateways, NAT gateways, S3 buckets, and VPC peering connections
- Access to the InfraHouse Terraform registry (`registry.infrahouse.com`)

## First Deployment

### 1. Create the management network

The management network must be created first. It acts as the hub that all
service networks peer with.

A network is identified as the management network when
`management_cidr_block` equals `vpc_cidr_block`.

```hcl
module "management" {
  source  = "registry.infrahouse.com/infrahouse/service-network/aws"
  version = "3.2.2"

  environment           = "production"
  service_name          = "management"
  vpc_cidr_block        = "10.1.0.0/16"
  management_cidr_block = "10.1.0.0/16"
  subnets = [
    {
      cidr                    = "10.1.0.0/24"
      availability_zone       = "us-west-2a"
      map_public_ip_on_launch = true
      create_nat              = true
    },
    {
      cidr              = "10.1.1.0/24"
      availability_zone = "us-west-2b"
      forward_to        = "10.1.0.0/24"
    },
    {
      cidr              = "10.1.2.0/24"
      availability_zone = "us-west-2c"
      forward_to        = "10.1.0.0/24"
    }
  ]
}
```

### 2. Create a service network

Service networks use a different `vpc_cidr_block` than the `management_cidr_block`,
which triggers automatic VPC peering with the management network.

```hcl
module "website" {
  source  = "registry.infrahouse.com/infrahouse/service-network/aws"
  version = "3.2.2"

  environment           = "production"
  service_name          = "website"
  vpc_cidr_block        = "10.3.0.0/16"
  management_cidr_block = "10.1.0.0/16"
  subnets = [
    {
      cidr                    = "10.3.0.0/24"
      availability_zone       = "us-west-2a"
      map_public_ip_on_launch = true
      create_nat              = true
    },
    {
      cidr              = "10.3.1.0/24"
      availability_zone = "us-west-2b"
      forward_to        = "10.3.0.0/24"
    }
  ]
}
```

### 3. Verify

After `terraform apply`, verify the setup:

- Check the VPC exists in the AWS console
- Confirm subnets are created in the expected availability zones
- For service networks, verify the VPC peering connection to the management VPC is active
- Check VPC Flow Logs are enabled and the S3 bucket is created

## Subnet Types

### Public subnets

Set `map_public_ip_on_launch = true`. These subnets route to the Internet Gateway.

### Private subnets with NAT

Set `create_nat = true` on one subnet to create a NAT Gateway there, then use
`forward_to` on other private subnets to route through it:

```hcl
subnets = [
  {
    cidr                    = "10.1.0.0/24"
    availability_zone       = "us-west-2a"
    map_public_ip_on_launch = true
    create_nat              = true  # NAT Gateway created here
  },
  {
    cidr              = "10.1.1.0/24"
    availability_zone = "us-west-2b"
    forward_to        = "10.1.0.0/24"  # Routes through the NAT above
  }
]
```

### Private subnets without internet access

Omit both `create_nat` and `forward_to`. The subnet will have no route to the
internet (only VPC-internal and peering traffic).
