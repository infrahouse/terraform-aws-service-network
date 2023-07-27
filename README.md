[![Documentation
Status](https://readthedocs.org/projects/terraform-aws-service-network/badge/?version=latest)](https://terraform-aws-service-network.readthedocs.io/en/latest/?badge=latest)

Service network is a VPC that hosts one logical unit of services. It can
be one service like MySQL or it can comprise of several services. For
example, a website with HTTP service and MySQL service.

One service network is an island. Instances inside the island can
communicate to each other and outside world.

Two different service networks cannot communicate to each other. This is
not a limitation but a security feature.

There is a special kind of service network - management service network.
It is a bridge between other service network. The management service
network can communicate to all other service networks. The management
network is needed to host common services like Chef server, bastion
hosts etc.

# Usage

The management network.

``` sourceCode terraform
module "management" {
  source                = "/path/to/module"
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

``` sourceCode terraform
module "website" {
  source                = "/path/to/module"
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
    }
  ]
}
```

## Requirements

| Name                                                                                                       | Version   |
| ---------------------------------------------------------------------------------------------------------- | --------- |
| :raw-html-m2r:<span class="title-ref">\<a name="requirement\_aws"\>\</a\></span> [aws](#requirement\\_aws) | \~\> 4.67 |

## Providers

| Name                                                                                                 | Version   |
| ---------------------------------------------------------------------------------------------------- | --------- |
| :raw-html-m2r:<span class="title-ref">\<a name="provider\_aws"\>\</a\></span> [aws](#provider\\_aws) | \~\> 4.67 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                     | Type        |
| -------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws\_default\_route\_table.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table)                    | resource    |
| [aws\_default\_security\_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group)              | resource    |
| [aws\_eip.nat\_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)                                                     | resource    |
| [aws\_internet\_gateway.ig](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)                                | resource    |
| [aws\_nat\_gateway.nat\_gw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway)                                     | resource    |
| [aws\_route.default\_main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                            | resource    |
| [aws\_route.route\_from\_me\_to\_mgmt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                | resource    |
| [aws\_route.route\_from\_mgmt\_to\_me](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                | resource    |
| [aws\_route.subnet\_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                          | resource    |
| [aws\_route.subnet\_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                           | resource    |
| [aws\_route\_table.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                                         | resource    |
| [aws\_route\_table\_association.private\_rt\_assoc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource    |
| [aws\_subnet.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                                    | resource    |
| [aws\_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)                                                          | resource    |
| [aws\_vpc\_peering\_connection.link\_to\_management](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection) | resource    |
| [aws\_route\_tables.mgmt\_route\_tables](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_tables)                    | data source |
| [aws\_vpc.management\_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc)                                           | data source |

## Inputs

| Name                                                                                                                                                         | Description                                                                | Type                                                                                                                                                                                                                                  | Default         | Required |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------- | -------- |
| :raw-html-m2r:<span class="title-ref">\<a name="input\_enable\_dns\_hostnames"\>\</a\></span> [enable\_dns\_hostnames](#input\\_enable\\_dns\\_hostnames)    | A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false. | `bool`                                                                                                                                                                                                                                | `false`         | no       |
| :raw-html-m2r:<span class="title-ref">\<a name="input\_enable\_dns\_support"\>\</a\></span> [enable\_dns\_support](#input\\_enable\\_dns\\_support)          | A boolean flag to enable/disable DNS support in the VPC. Defaults true.    | `bool`                                                                                                                                                                                                                                | `true`          | no       |
| :raw-html-m2r:<span class="title-ref">\<a name="input\_environment"\>\</a\></span> [environment](#input\\_environment)                                       | Name of environment                                                        | `string`                                                                                                                                                                                                                              | `"development"` | no       |
| :raw-html-m2r:<span class="title-ref">\<a name="input\_management\_cidr\_block"\>\</a\></span> [management\_cidr\_block](#input\\_management\\_cidr\\_block) | Management VPC cidr block                                                  | `any`                                                                                                                                                                                                                                 | n/a             | yes      |
| :raw-html-m2r:<span class="title-ref">\<a name="input\_service\_name"\>\</a\></span> [service\_name](#input\\_service\\_name)                                | Descriptive name of a service that will use this VPC                       | `any`                                                                                                                                                                                                                                 | n/a             | yes      |
| :raw-html-m2r:<span class="title-ref">\<a name="input\_subnets"\>\</a\></span> [subnets](#input\\_subnets)                                                   | List of subnets in the VPC                                                 | :raw-html-m2r:<span class="title-ref">\<pre\>list(object({\<br\> cidr = string\<br\> availability-zone = string\<br\> map\_public\_ip\_on\_launch = bool\<br\> create\_nat = bool\<br\> forward\_to = string\<br\> }))\</pre\></span> | `[]`            | no       |
| :raw-html-m2r:<span class="title-ref">\<a name="input\_tags"\>\</a\></span> [tags](#input\\_tags)                                                            | Tags to apply to each resource                                             | `map`                                                                                                                                                                                                                                 | `{}`            | no       |
| :raw-html-m2r:<span class="title-ref">\<a name="input\_vpc\_cidr\_block"\>\</a\></span> [vpc\_cidr\_block](#input\\_vpc\\_cidr\\_block)                      | Block of IP addresses used for this VPC                                    | `any`                                                                                                                                                                                                                                 | n/a             | yes      |

## Outputs

| Name                                                                                                                                                           | Description |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| :raw-html-m2r:<span class="title-ref">\<a name="output\_internet\_gateway\_id"\>\</a\></span> [internet\_gateway\_id](#output\\_internet\\_gateway\\_id)       | n/a         |
| :raw-html-m2r:<span class="title-ref">\<a name="output\_is\_management\_network"\>\</a\></span> [is\_management\_network](#output\\_is\\_management\\_network) | n/a         |
| :raw-html-m2r:<span class="title-ref">\<a name="output\_management\_cidr\_block"\>\</a\></span> [management\_cidr\_block](#output\\_management\\_cidr\\_block) | n/a         |
| :raw-html-m2r:<span class="title-ref">\<a name="output\_subnet\_all\_ids"\>\</a\></span> [subnet\_all\_ids](#output\\_subnet\\_all\\_ids)                      | n/a         |
| :raw-html-m2r:<span class="title-ref">\<a name="output\_subnet\_private\_ids"\>\</a\></span> [subnet\_private\_ids](#output\\_subnet\\_private\\_ids)          | n/a         |
| :raw-html-m2r:<span class="title-ref">\<a name="output\_subnet\_public\_ids"\>\</a\></span> [subnet\_public\_ids](#output\\_subnet\\_public\\_ids)             | n/a         |
| :raw-html-m2r:<span class="title-ref">\<a name="output\_vpc\_cidr\_block"\>\</a\></span> [vpc\_cidr\_block](#output\\_vpc\\_cidr\\_block)                      | n/a         |
| :raw-html-m2r:<span class="title-ref">\<a name="output\_vpc\_id"\>\</a\></span> [vpc\_id](#output\\_vpc\\_id)                                                  | n/a         |
