===============
Service network
===============

.. image:: https://readthedocs.org/projects/terraform-aws-service-network/badge/?version=latest
    :target: https://terraform-aws-service-network.readthedocs.io/en/latest/?badge=latest
    :alt: Documentation Status


Service network is a VPC that hosts one logical unit of services.
It can be one service like MySQL or it can comprise of several services.
For example, a website with HTTP service and MySQL service.

One service network is an island. Instances inside the island
can communicate to each other and outside world.

Two different service networks cannot communicate to each other.
This is not a limitation but a security feature.

There is a special kind of service network - management service network.
It is a bridge between other service network.
The management service network can communicate to all other service networks.
The management network is needed to host common services like Chef server, bastion hosts etc.

Usage
=====

The management network.

.. code-block:: terraform

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

Service network (for website or other service).

.. code-block:: terraform

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

.. role:: raw-html-m2r(raw)
   :format: html


Requirements
------------

.. list-table::
   :header-rows: 1

   * - Name
     - Version
   * - :raw-html-m2r:`<a name="requirement_aws"></a>` `aws <#requirement\_aws>`_
     - ~> 4.67


Providers
---------

.. list-table::
   :header-rows: 1

   * - Name
     - Version
   * - :raw-html-m2r:`<a name="provider_aws"></a>` `aws <#provider\_aws>`_
     - ~> 4.67


Modules
-------

No modules.

Resources
---------

.. list-table::
   :header-rows: 1

   * - Name
     - Type
   * - `aws_default_route_table.default <https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table>`_
     - resource
   * - `aws_default_security_group.default <https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group>`_
     - resource
   * - `aws_eip.nat_eip <https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip>`_
     - resource
   * - `aws_internet_gateway.ig <https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway>`_
     - resource
   * - `aws_nat_gateway.nat_gw <https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway>`_
     - resource
   * - `aws_route.default_main <https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route>`_
     - resource
   * - `aws_route.route_from_me_to_mgmt <https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route>`_
     - resource
   * - `aws_route.route_from_mgmt_to_me <https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route>`_
     - resource
   * - `aws_route.subnet_private <https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route>`_
     - resource
   * - `aws_route.subnet_public <https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route>`_
     - resource
   * - `aws_route_table.all <https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table>`_
     - resource
   * - `aws_route_table_association.private_rt_assoc <https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association>`_
     - resource
   * - `aws_subnet.all <https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet>`_
     - resource
   * - `aws_vpc.vpc <https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc>`_
     - resource
   * - `aws_vpc_peering_connection.link_to_management <https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection>`_
     - resource
   * - `aws_route_tables.mgmt_route_tables <https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_tables>`_
     - data source
   * - `aws_vpc.management_vpc <https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc>`_
     - data source


Inputs
------

.. list-table::
   :header-rows: 1

   * - Name
     - Description
     - Type
     - Default
     - Required
   * - :raw-html-m2r:`<a name="input_enable_dns_hostnames"></a>` `enable_dns_hostnames <#input\_enable\_dns\_hostnames>`_
     - A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false.
     - ``bool``
     - ``false``
     - no
   * - :raw-html-m2r:`<a name="input_enable_dns_support"></a>` `enable_dns_support <#input\_enable\_dns\_support>`_
     - A boolean flag to enable/disable DNS support in the VPC. Defaults true.
     - ``bool``
     - ``true``
     - no
   * - :raw-html-m2r:`<a name="input_environment"></a>` `environment <#input\_environment>`_
     - Name of environment
     - ``string``
     - ``"development"``
     - no
   * - :raw-html-m2r:`<a name="input_management_cidr_block"></a>` `management_cidr_block <#input\_management\_cidr\_block>`_
     - Management VPC cidr block
     - ``any``
     - n/a
     - yes
   * - :raw-html-m2r:`<a name="input_service_name"></a>` `service_name <#input\_service\_name>`_
     - Descriptive name of a service that will use this VPC
     - ``any``
     - n/a
     - yes
   * - :raw-html-m2r:`<a name="input_subnets"></a>` `subnets <#input\_subnets>`_
     - List of subnets in the VPC
     - :raw-html-m2r:`<pre>list(object({<br>    cidr                    = string<br>    availability-zone       = string<br>    map_public_ip_on_launch = bool<br>    create_nat              = bool<br>    forward_to              = string<br>  }))</pre>`
     - ``[]``
     - no
   * - :raw-html-m2r:`<a name="input_tags"></a>` `tags <#input\_tags>`_
     - Tags to apply to each resource
     - ``map``
     - ``{}``
     - no
   * - :raw-html-m2r:`<a name="input_vpc_cidr_block"></a>` `vpc_cidr_block <#input\_vpc\_cidr\_block>`_
     - Block of IP addresses used for this VPC
     - ``any``
     - n/a
     - yes


Outputs
-------

.. list-table::
   :header-rows: 1

   * - Name
     - Description
   * - :raw-html-m2r:`<a name="output_internet_gateway_id"></a>` `internet_gateway_id <#output\_internet\_gateway\_id>`_
     - n/a
   * - :raw-html-m2r:`<a name="output_is_management_network"></a>` `is_management_network <#output\_is\_management\_network>`_
     - n/a
   * - :raw-html-m2r:`<a name="output_management_cidr_block"></a>` `management_cidr_block <#output\_management\_cidr\_block>`_
     - n/a
   * - :raw-html-m2r:`<a name="output_subnet_all_ids"></a>` `subnet_all_ids <#output\_subnet\_all\_ids>`_
     - n/a
   * - :raw-html-m2r:`<a name="output_subnet_private_ids"></a>` `subnet_private_ids <#output\_subnet\_private\_ids>`_
     - n/a
   * - :raw-html-m2r:`<a name="output_subnet_public_ids"></a>` `subnet_public_ids <#output\_subnet\_public\_ids>`_
     - n/a
   * - :raw-html-m2r:`<a name="output_vpc_cidr_block"></a>` `vpc_cidr_block <#output\_vpc\_cidr\_block>`_
     - n/a
   * - :raw-html-m2r:`<a name="output_vpc_id"></a>` `vpc_id <#output\_vpc\_id>`_
     - n/a

