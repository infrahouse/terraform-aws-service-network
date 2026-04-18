# Configuration

## Required Variables

### `environment`

The environment name (e.g., `production`, `staging`, `development`). Used in resource
tags. No default is provided -- you must set this explicitly.

```hcl
environment = "production"
```

### `service_name`

A descriptive name for the service that will use this VPC. Used in resource naming
and tags.

```hcl
service_name = "website"
```

### `vpc_cidr_block`

The CIDR block for the VPC. Must be a valid IPv4 CIDR block.

```hcl
vpc_cidr_block = "10.3.0.0/16"
```

### `management_cidr_block`

The CIDR block of the management VPC. When this equals `vpc_cidr_block`, the network
is treated as the management network (no peering is created). When different, the module
automatically creates a VPC peering connection to the management VPC.

```hcl
# Management network (self-referencing):
management_cidr_block = "10.1.0.0/16"  # same as vpc_cidr_block

# Service network (peers with management):
management_cidr_block = "10.1.0.0/16"  # different from vpc_cidr_block
```

## Subnet Configuration

### `subnets`

A list of subnet objects. Each subnet supports:

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `cidr` | string | required | CIDR block for the subnet |
| `availability_zone` | string | required | AWS availability zone |
| `map_public_ip_on_launch` | bool | `false` | Assign public IPs to instances |
| `create_nat` | bool | `false` | Create a NAT Gateway in this subnet |
| `forward_to` | string | `null` | CIDR of subnet whose NAT Gateway to use |
| `tags` | map(string) | `{}` | Additional tags for the subnet |

!!! note
    The `availability-zone` key (with hyphen) is deprecated. Use `availability_zone`
    (with underscore) instead. Both are accepted in the current version, but
    `availability-zone` will be removed in a future major release.

#### Example: Multi-AZ with public and private subnets

```hcl
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
    tags = {
      role = "database"
    }
  }
]
```

## Optional Variables

### DNS Settings

```hcl
enable_dns_support   = true   # Default: true
enable_dns_hostnames = true   # Default: true

# Respond to DNS queries for instance hostnames with A records
enable_resource_name_dns_a_record_on_launch = false  # Default: false
```

### Security Group

```hcl
# Deny all traffic on the default security group (recommended)
restrict_all_traffic = true  # Default: true

# When restrict_all_traffic = false, scope allowed traffic to this CIDR
# Defaults to vpc_cidr_block when null
default_security_group_cidr = null  # Default: null
```

### VPC Flow Logs

```hcl
# Enable/disable VPC Flow Logs
enable_vpc_flow_logs = true  # Default: true

# Retention period in days (365 for ISO/SOC compliance)
vpc_flow_retention_days = 365  # Default: 365

# Allow terraform destroy to delete flow logs bucket with contents
flow_logs_force_destroy = false  # Default: false
```

!!! warning
    Setting `flow_logs_force_destroy = true` allows Terraform to delete the flow logs
    S3 bucket and all its contents. Only use this in test environments.

### Tags

```hcl
# Additional tags applied to all resources
tags = {
  team    = "platform"
  project = "infrastructure"
}
```
