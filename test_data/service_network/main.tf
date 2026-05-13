resource "random_string" "test-id" {
  length  = 6
  special = false
}

module "test_network" {
  source                  = "./../../"
  environment             = var.environment
  service_name            = var.service_name
  vpc_cidr_block          = var.vpc_cidr_block
  management_cidr_block   = var.management_cidr_block
  subnets                 = var.subnets
  restrict_all_traffic    = var.restrict_all_traffic
  flow_logs_force_destroy = true
  replication_region      = var.replication_region
  tags = {
    test_id : random_string.test-id.result
  }
}
