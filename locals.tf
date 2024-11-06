locals {
  is_management_network = var.management_cidr_block == var.vpc_cidr_block
  subnets_with_nat      = [for subnet in var.subnets : subnet if subnet.create_nat == true]
  subnets_without_nat   = [for subnet in var.subnets : subnet if subnet.create_nat == false]
  subnets_private       = [for subnet in var.subnets : subnet if subnet.map_public_ip_on_launch == false]
  subnets_public        = [for subnet in var.subnets : subnet if subnet.map_public_ip_on_launch == true]
}
