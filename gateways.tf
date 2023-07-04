# Internet Gateway to let the public network access Internet
# It will be the default route for the main routing table
# and the default route for public subnets
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    {
      "Name"        = "Internet gateway"
      "environment" = var.environment
      "service"     = var.service_name
    }
  )
}

# Each subnet may have its own NAT. The subnet with NAT must be
# public i.e. assign public IPv4 to EC2 instances.
resource "aws_nat_gateway" "nat_gw" {
  for_each      = toset([for s in local.subnets_with_nat : s.cidr])
  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = aws_subnet.all[each.key].id

  tags = merge(
    var.tags,
    {
      "Name"        = "NAT gateway"
      "residency"   = each.key
      "environment" = var.environment
      "service"     = var.service_name
    }
  )
}

# Each NAT gateway needs an elastic IP
resource "aws_eip" "nat_eip" {
  for_each = toset([for s in local.subnets_with_nat : s.cidr])
  vpc      = true
  tags = merge(
    var.tags,
    {
      "Name"        = "Elastic IP for NAT gateway"
      "residency"   = each.key
      "environment" = var.environment
      "service"     = var.service_name
    }
  )
}
