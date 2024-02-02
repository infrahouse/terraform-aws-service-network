variable "environment" {
  default = "dev"
}

variable "region" {}

variable "service_name" {
  description = "Descriptive name of a service that will use this VPC"
  default     = "my service"
}

variable "management_cidr_block" {
  description = "Management VPC cidr block"
}

variable "subnets" {
  description = "List of subnets in the VPC"
  type = list(object({
    cidr                    = string
    availability-zone       = string
    map_public_ip_on_launch = bool
    create_nat              = bool
    forward_to              = string
  }))
  default = []
}

variable "vpc_cidr_block" {
  description = "Block of IP addresses used for this VPC"
}

variable "restrict_all_traffic" {
  type = bool
}
