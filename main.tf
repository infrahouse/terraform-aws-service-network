# A separate VPC is created for a service
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    {
      "Name"         = "VPC for ${var.service_name} (${var.environment}) ${var.vpc_cidr_block}"
      "management"   = local.is_management_network
      module_version = local.module_version
    },
    local.default_module_tags
  )
  lifecycle {
    create_before_destroy = true
  }
}
