variable "environment" {
  type    = string
  default = "dev"
}

variable "region" {
  type = string
}

variable "role_arn" {
  type    = string
  default = null
}

variable "service_name" {
  description = "Descriptive name of a service that will use this VPC"
  type        = string
  default     = "my service"
}

variable "management_cidr_block" {
  description = "Management VPC cidr block"
  type        = string
}

variable "subnets" {
  description = "List of subnets in the VPC"
  type = list(
    object(
      {
        cidr                    = string
        availability-zone       = string
        map_public_ip_on_launch = optional(bool, false)
        create_nat              = optional(bool, false)
        forward_to              = optional(string, null)
        tags                    = optional(map(string), {})
      }
    )
  )
  default = []
}

variable "vpc_cidr_block" {
  description = "Block of IP addresses used for this VPC"
  type        = string
}

variable "restrict_all_traffic" {
  type = bool
}

variable "enable_vpc_flow_logs" {
  type    = bool
  default = false
}
