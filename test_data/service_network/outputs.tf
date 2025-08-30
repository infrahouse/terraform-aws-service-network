output "subnets_all" {
  value = module.test_network.subnet_all_ids
}

output "subnets_public" {
  value = module.test_network.subnet_public_ids
}

output "subnets_private" {
  value = module.test_network.subnet_private_ids
}

output "internet_gateway_id" {
  value = module.test_network.internet_gateway_id
}

output "vpc_id" {
  value = module.test_network.vpc_id
}

output "route_table_all" {
  value = module.test_network.route_table_all_ids
}

output "client_instances" {
  description = "Map with subnet id as key and client instance id as value"
  value       = aws_instance.client_instance[*].id
}

output "test_id" {
  description = "Random string that helps to find resources created by this module"
  value       = random_string.test-id.result
}
