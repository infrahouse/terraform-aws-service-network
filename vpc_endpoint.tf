resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  tags = merge(
    {
      "Name" = "S3 Endpoint in ${var.service_name} VPC"
    },
    local.default_module_tags
  )
}

resource "aws_vpc_endpoint_route_table_association" "example" {
  for_each        = toset([for k in var.subnets : k.cidr])
  route_table_id  = aws_route_table.all[each.key].id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}
