output "internet_gateway_id" {
  description = "The ID of the Internet Gateway attached to the VPC"
  value       = aws_internet_gateway.ig.id
}

output "is_management_network" {
  description = "Boolean indicating whether this is a management network"
  value       = local.is_management_network
}

output "management_cidr_block" {
  description = "The CIDR block of the management VPC"
  value       = var.management_cidr_block
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = var.vpc_cidr_block
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "subnet_all_ids" {
  description = "List of IDs of all subnets"
  value = [
    for subnet in aws_subnet.all : subnet.id
  ]
}
output "subnet_private_ids" {
  description = "List of IDs of private subnets"
  value = [
    for subnet in aws_subnet.all : subnet.id if !subnet.map_public_ip_on_launch
  ]
}

output "subnet_public_ids" {
  description = "List of IDs of public subnets"
  value = [
    for subnet in aws_subnet.all : subnet.id if subnet.map_public_ip_on_launch
  ]
}

output "route_table_all_ids" {
  description = "List of IDs of all route tables"
  value = [
    for subnet in aws_subnet.all : aws_route_table.all[subnet.cidr_block].id
  ]
}

output "vpc_flow_bucket_name" {
  description = "S3 bucket name with VPC Flow logs if enabled"
  value       = var.enable_vpc_flow_logs ? aws_s3_bucket.vpc_flow_logs[0].bucket : null
}
