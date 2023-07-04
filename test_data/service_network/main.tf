module "test_network" {
  source                = "./../../"
  environment           = var.environment
  service_name          = var.service_name
  vpc_cidr_block        = var.vpc_cidr_block
  management_cidr_block = var.management_cidr_block
  subnets               = var.subnets
}
