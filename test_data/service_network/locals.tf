locals {
  ubuntu_codename      = "noble"
  ami_name_pattern_pro = "ubuntu-pro-server/images/hvm-ssd-gp3/ubuntu-${local.ubuntu_codename}-*"

  ami_id = data.aws_ami.ubuntu_pro.id
}
