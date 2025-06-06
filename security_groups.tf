# Default security group for the service network allows
# all traffic
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    {
      "Name" = "${var.vpc_cidr_block} default"
    },
    local.default_module_tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "default" {
  count             = var.restrict_all_traffic ? 0 : 1
  description       = "Allow all traffic"
  security_group_id = aws_default_security_group.default.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  tags = merge(
    {
      Name = "incoming traffic"
    },

    local.default_module_tags
  )
}

resource "aws_vpc_security_group_egress_rule" "default" {
  count             = var.restrict_all_traffic ? 0 : 1
  description       = "Allow all traffic"
  security_group_id = aws_default_security_group.default.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  tags = merge(
    {
      Name = "outgoing traffic"
    },
    local.default_module_tags
  )
}
