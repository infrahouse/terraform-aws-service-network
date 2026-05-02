# terraform-aws-service-network

A Terraform module that creates isolated AWS VPC "service networks" with an optional
management network peering topology.

## Overview

A service network is a VPC that hosts one logical unit of services. It can be one service
like MySQL, or it can comprise several services -- for example, a website with HTTP and
MySQL services.

Each service network is an island. Instances inside the island can communicate with each
other and the outside world, but two different service networks cannot communicate with
each other directly. This is a security feature, not a limitation.

A special **management service network** acts as a bridge between other service networks,
creating a hub-and-spoke topology. The management network can communicate with all other
service networks and is used to host common services like bastion hosts, monitoring, etc.

## Features

- Creates a VPC with configurable CIDR block and DNS settings
- Dynamic subnet creation with per-subnet control over:
    - Public IP mapping
    - NAT gateway creation
    - Traffic forwarding to NAT gateways in other subnets
    - Custom tags
- Automatic hub-and-spoke peering with a management VPC
- VPC Flow Logs to S3 with 365-day retention (ISO/SOC compliant)
- S3 gateway endpoint for private S3 access
- Restrictive default security group (configurable)
- Internet Gateway and optional per-subnet NAT Gateways with Elastic IPs

## Quick Start

```hcl
module "network" {
  source  = "registry.infrahouse.com/infrahouse/service-network/aws"
  version = "4.0.0"

  environment           = "production"
  service_name          = "my-service"
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
    }
  ]
}
```

## Architecture

![Architecture](assets/architecture.svg)

A network is identified as the management network when
`management_cidr_block == vpc_cidr_block`. Service networks (where these differ)
automatically peer with the management VPC.
