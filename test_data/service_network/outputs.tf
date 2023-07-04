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
