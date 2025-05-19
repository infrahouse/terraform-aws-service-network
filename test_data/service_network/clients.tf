data "aws_iam_policy_document" "client-permissions" {
  statement {
    actions   = ["sts:getCallerIdentity"]
    resources = ["*"]
  }
}

module "instance-profile" {
  source       = "registry.infrahouse.com/infrahouse/instance-profile/aws"
  version      = "1.8.1"
  permissions  = data.aws_iam_policy_document.client-permissions.json
  profile_name = "service-network-client"
}

resource "tls_private_key" "client" {
  algorithm = "RSA"
}

resource "aws_key_pair" "client" {
  key_name_prefix = "client-generated-"
  public_key      = tls_private_key.client.public_key_openssh
}


resource "aws_launch_template" "client" {
  name_prefix   = "client-"
  instance_type = "t3a.micro"
  key_name      = aws_key_pair.client.key_name
  image_id      = data.aws_ami.ubuntu_pro.id
  iam_instance_profile {
    arn = module.instance-profile.instance_profile_arn
  }
  block_device_mappings {
    device_name = data.aws_ami.ubuntu_pro.root_device_name
    ebs {
      volume_size           = 8
      delete_on_termination = true
      encrypted             = true
    }
  }
  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }
  vpc_security_group_ids = [
    aws_security_group.client.id
  ]
  tag_specifications {
    resource_type = "volume"
    tags = merge(
      data.aws_default_tags.provider.tags,
    )
  }
  tag_specifications {
    resource_type = "network-interface"
    tags = merge(
      data.aws_default_tags.provider.tags,
    )
  }
}

resource "aws_security_group" "client" {
  vpc_id      = module.test_network.vpc_id
  name_prefix = "client"
  description = "Service network client security group"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          // All protocols
    cidr_blocks = ["0.0.0.0/0"] // Allow all incoming traffic
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          // All protocols
    cidr_blocks = ["0.0.0.0/0"] // Allow all outgoing traffic
  }
}


resource "aws_instance" "client_instance" {
  count     = length(module.test_network.subnet_all_ids)
  subnet_id = module.test_network.subnet_all_ids[count.index]
  launch_template {
    id      = aws_launch_template.client.id
    version = "$Latest"
  }
  vpc_security_group_ids = [
    aws_security_group.client.id
  ]

}
