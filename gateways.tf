# Internet Gateway to let the public network access Internet
# It will be the default route for the main routing table
# and the default route for public subnets
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    {
      "Name" = "Internet gateway"
    },
    local.default_module_tags
  )
}

# Each subnet may have its own NAT. The subnet with NAT must be
# public i.e. assign public IPv4 to EC2 instances.
resource "aws_nat_gateway" "nat_gw" {
  for_each      = toset([for s in local.subnets_with_nat : s.cidr])
  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = aws_subnet.all[each.key].id

  tags = merge(
    {
      "Name"      = "NAT gateway"
      "residency" = each.key
    },
    local.default_module_tags

  )
}

# Each NAT gateway needs an elastic IP
resource "aws_eip" "nat_eip" {
  for_each = toset([for s in local.subnets_with_nat : s.cidr])
  domain   = "vpc"
  tags = merge(
    {
      "Name"      = "Elastic IP for NAT gateway"
      "residency" = each.key
    },
    local.default_module_tags
  )
}
