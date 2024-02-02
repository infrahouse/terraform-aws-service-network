# Default security group for the service network allows
# all traffic
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    var.tags,
    {
      "Name"        = "${var.vpc_cidr_block} default"
      "environment" = var.environment
      "service"     = var.service_name
    }
  )

}

resource "aws_vpc_security_group_ingress_rule" "default" {
  count             = var.restrict_all_traffic == true ? 0 : 1
  description       = "Allow all traffic"
  security_group_id = aws_default_security_group.default.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    Name = "incoming traffic"
  }
}

resource "aws_vpc_security_group_egress_rule" "default" {
  count             = var.restrict_all_traffic == true ? 0 : 1
  description       = "Allow all traffic"
  security_group_id = aws_default_security_group.default.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    Name = "outgoing traffic"
  }
}
