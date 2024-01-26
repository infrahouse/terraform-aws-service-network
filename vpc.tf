# A separate VPC is created for a service
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    var.tags,
    {
      "Name"        = "VPC for ${var.service_name} (${var.environment}) ${var.vpc_cidr_block}"
      "environment" = var.environment
      "service"     = var.service_name
      "management"  = local.is_management_network
    }
  )
  lifecycle {
    create_before_destroy = true
  }
}
