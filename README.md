![Service Network](https://github.com/infrahouse/terraform-aws-service-network/assets/1763754/14018b73-7e3c-4687-8a96-89fb1c5895c0)
A service network is a VPC that hosts one logical unit of services. It can
be one service like MySQL, or it can comprise several services. For
example, a website with HTTP service and MySQL service.

One service network is an island. Instances inside the island can
communicate with each other and the outside world.

Two different service networks cannot communicate with each other. This is
not a limitation but a security feature.

There is a special kind of service network - a management service network.
It is a bridge between other service networks. The management service
network can communicate with all other service networks. The management
network is needed to host common services like Chef server, bastion
hosts, etc.

# Usage

The management network.

```hcl
module "management" {
  source  = "infrahouse/service-network/aws"
  version = "3.1.2"

  environment           = "dev"
  service_name          = "management"
  vpc_cidr_block        = "10.1.0.0/16"
  management_cidr_block = "10.1.0.0/16"
  subnets = [
    {
      cidr                    = "10.1.0.0/24"
      availability-zone       = "${var.region}a"
      map_public_ip_on_launch = true
      create_nat              = true
      forward_to              = null
    },
    {
      cidr                    = "10.1.1.0/24"
      availability-zone       = "${var.region}b"
      map_public_ip_on_launch = false
      create_nat              = false
      forward_to              = "10.1.0.0/24"
    },
    {
      cidr                    = "10.1.2.0/24"
      availability-zone       = "${var.region}c"
      map_public_ip_on_launch = false
      create_nat              = false
      forward_to              = "10.1.0.0/24"
    }
  ]
}
```

Service network (for website or other service).

```hcl
module "website" {
  source  = "infrahouse/service-network/aws"
  version = "3.1.2"

  environment           = "dev"
  service_name          = "website"
  vpc_cidr_block        = "10.3.0.0/16"
  management_cidr_block = "10.1.0.0/16"
  subnets = [
    {
      cidr                    = "10.3.0.0/24"
      availability-zone       = "${var.region}a"
      map_public_ip_on_launch = true
      create_nat              = true
      forward_to              = null

    },
    {
      cidr                    = "10.3.1.0/24"
      availability-zone       = "${var.region}b"
      map_public_ip_on_launch = false
      create_nat              = false
      forward_to              = "10.3.0.0/24"
      tags                    = {
        region = "${var.region}b"
      }
    }
  ]
}
```
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.11 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.11 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_default_route_table.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_eip.nat_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_flow_log.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_internet_gateway.ig](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.nat_gw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.default_main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.route_from_me_to_mgmt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.route_from_mgmt_to_me](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.subnet_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.subnet_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private_rt_assoc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_s3_bucket.vpc_flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.vpc_flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_public_access_block.public_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.enabled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_subnet.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint_route_table_association.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association) | resource |
| [aws_vpc_peering_connection.link_to_management](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection) | resource |
| [aws_vpc_security_group_egress_rule.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route_tables.mgmt_route_tables](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_tables) | data source |
| [aws_vpc.management_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false. | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | A boolean flag to enable/disable DNS support in the VPC. Defaults true. | `bool` | `true` | no |
| <a name="input_enable_resource_name_dns_a_record_on_launch"></a> [enable\_resource\_name\_dns\_a\_record\_on\_launch](#input\_enable\_resource\_name\_dns\_a\_record\_on\_launch) | Indicates whether to respond to DNS queries for instance hostnames with DNS A records. | `bool` | `false` | no |
| <a name="input_enable_vpc_flow_logs"></a> [enable\_vpc\_flow\_logs](#input\_enable\_vpc\_flow\_logs) | Whether to enable VPC Flow Logs. Default, false. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Name of environment | `string` | `"development"` | no |
| <a name="input_management_cidr_block"></a> [management\_cidr\_block](#input\_management\_cidr\_block) | Management VPC cidr block | `any` | n/a | yes |
| <a name="input_restrict_all_traffic"></a> [restrict\_all\_traffic](#input\_restrict\_all\_traffic) | Whether the default security group should deny all traffic | `bool` | `true` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Descriptive name of a service that will use this VPC | `any` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | List of subnets in the VPC | <pre>list(<br/>    object(<br/>      {<br/>        cidr                    = string<br/>        availability-zone       = string<br/>        map_public_ip_on_launch = bool<br/>        create_nat              = bool<br/>        forward_to              = string<br/>        tags                    = optional(map(string), {})<br/>      }<br/>    )<br/>  )</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to each resource | `map` | `{}` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | Block of IP addresses used for this VPC | `any` | n/a | yes |
| <a name="input_vpc_flow_retention_days"></a> [vpc\_flow\_retention\_days](#input\_vpc\_flow\_retention\_days) | Retention period for VPC flow logs in S3 bucket. | `number` | `7` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_internet_gateway_id"></a> [internet\_gateway\_id](#output\_internet\_gateway\_id) | n/a |
| <a name="output_is_management_network"></a> [is\_management\_network](#output\_is\_management\_network) | n/a |
| <a name="output_management_cidr_block"></a> [management\_cidr\_block](#output\_management\_cidr\_block) | n/a |
| <a name="output_route_table_all_ids"></a> [route\_table\_all\_ids](#output\_route\_table\_all\_ids) | n/a |
| <a name="output_subnet_all_ids"></a> [subnet\_all\_ids](#output\_subnet\_all\_ids) | n/a |
| <a name="output_subnet_private_ids"></a> [subnet\_private\_ids](#output\_subnet\_private\_ids) | n/a |
| <a name="output_subnet_public_ids"></a> [subnet\_public\_ids](#output\_subnet\_public\_ids) | n/a |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | n/a |
| <a name="output_vpc_flow_bucket_name"></a> [vpc\_flow\_bucket\_name](#output\_vpc\_flow\_bucket\_name) | S3 bucket name with VPC Flow logs if enabled |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |
