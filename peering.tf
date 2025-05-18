data "aws_vpc" "management_vpc" {
  count      = local.is_management_network ? 0 : 1
  cidr_block = var.management_cidr_block
}

data "aws_route_tables" "mgmt_route_tables" {
  count  = local.is_management_network ? 0 : 1
  vpc_id = data.aws_vpc.management_vpc[0].id
}

resource "aws_vpc_peering_connection" "link_to_management" {
  count       = local.is_management_network ? 0 : 1
  peer_vpc_id = local.is_management_network ? aws_vpc.vpc.id : data.aws_vpc.management_vpc[0].id
  vpc_id      = aws_vpc.vpc.id
  auto_accept = true
  tags        = local.default_module_tags
}
