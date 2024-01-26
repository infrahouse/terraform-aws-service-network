output "internet_gateway_id" {
  value = aws_internet_gateway.ig.id
}

output "is_management_network" {
  value = local.is_management_network
}

output "management_cidr_block" {
  value = var.management_cidr_block
}

output "vpc_cidr_block" {
  value = var.vpc_cidr_block
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet_all_ids" {
  value = [
    for subnet in aws_subnet.all : subnet.id
  ]
}
output "subnet_private_ids" {
  value = [
    for subnet in aws_subnet.all : subnet.id if subnet.map_public_ip_on_launch == false
  ]
}

output "subnet_public_ids" {
  value = [
    for subnet in aws_subnet.all : subnet.id if subnet.map_public_ip_on_launch == true
  ]
}

output "route_table_all_ids" {
  value = [
    for subnet in aws_subnet.all : aws_route_table.all[subnet.cidr_block].id
  ]
}
