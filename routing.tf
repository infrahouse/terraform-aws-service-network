# Routing
# There is a default routing table
resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  tags = merge(
    {
      "Name"      = "Main table for ${aws_vpc.vpc.cidr_block}"
      "residency" = aws_vpc.vpc.cidr_block
    },
    local.default_module_tags
  )
}

# The default route forwards packets to the Internet gateway
resource "aws_route" "default_main" {
  route_table_id         = aws_default_route_table.default.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

# One routing table for a subnet
resource "aws_route_table" "all" {
  for_each = toset([for k in var.subnets : k.cidr])
  vpc_id   = aws_vpc.vpc.id
  tags = merge(
    {
      "Name"      = "Table for ${each.key}"
      "residency" = each.key
    },
    local.default_module_tags
  )
}

# The default route forwards packets to the NAT gateway
resource "aws_route" "subnet_public" {
  for_each               = toset([for k in local.subnets_public : k.cidr])
  route_table_id         = aws_route_table.all[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_route" "subnet_private" {
  for_each = {
    for s in local.subnets_private : s.cidr => s if s.forward_to != null
  }
  route_table_id         = aws_route_table.all[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[each.value.forward_to].id
}

resource "aws_route_table_association" "private_rt_assoc" {
  for_each       = toset([for k in var.subnets : k.cidr])
  subnet_id      = aws_subnet.all[each.key].id
  route_table_id = aws_route_table.all[each.key].id
}

# Routes from management VPC to this VPC
resource "aws_route" "route_from_mgmt_to_me" {
  count                     = local.is_management_network ? 0 : length(data.aws_route_tables.mgmt_route_tables[0].ids)
  route_table_id            = tolist(data.aws_route_tables.mgmt_route_tables[0].ids)[count.index]
  destination_cidr_block    = var.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.link_to_management[0].id
}

# Routes from this VPC to management VPC
resource "aws_route" "route_from_me_to_mgmt" {
  for_each                  = toset([for k in var.subnets : k.cidr if local.is_management_network != true])
  route_table_id            = aws_route_table.all[each.key].id
  destination_cidr_block    = var.management_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.link_to_management[0].id
}

