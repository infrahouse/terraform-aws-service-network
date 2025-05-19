locals {
  module_name    = "infrahouse/service-network/aws"
  module_version = "3.1.1"

  default_module_tags = merge(
    {
      environment : var.environment
      service : var.service_name
      created_by_module : local.module_name
    },
    var.tags
  )

  is_management_network = var.management_cidr_block == var.vpc_cidr_block
  subnets_with_nat      = [for subnet in var.subnets : subnet if subnet.create_nat]
  subnets_without_nat   = [for subnet in var.subnets : subnet if !subnet.create_nat]
  subnets_private       = [for subnet in var.subnets : subnet if !subnet.map_public_ip_on_launch]
  subnets_public        = [for subnet in var.subnets : subnet if subnet.map_public_ip_on_launch]
}
