resource "aws_subnet" "all" {
  for_each                                    = { for s in var.subnets : s.cidr => s }
  cidr_block                                  = each.value.cidr
  vpc_id                                      = aws_vpc.vpc.id
  availability_zone                           = each.value.availability-zone
  map_public_ip_on_launch                     = each.value.map_public_ip_on_launch
  enable_resource_name_dns_a_record_on_launch = var.enable_resource_name_dns_a_record_on_launch

  tags = merge(
    var.tags,
    {
      "Name"        = "${var.service_name}: ${each.value.map_public_ip_on_launch ? "public" : "private"} ${each.key}"
      "environment" = var.environment
      "service"     = var.service_name
      "management"  = local.is_management_network
    }
  )
}
