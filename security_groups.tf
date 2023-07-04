# Default security group for the service network allows
# all traffic
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol  = -1
    from_port = 0
    to_port   = 0
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    protocol  = -1
    from_port = 0
    to_port   = 0
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = merge(
    var.tags,
    {
      "Name"        = "${var.vpc_cidr_block} default"
      "environment" = var.environment
      "service"     = var.service_name
    }
  )

}
