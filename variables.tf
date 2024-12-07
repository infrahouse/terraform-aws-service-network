variable "enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC. Defaults true."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false."
  type        = bool
  default     = false
}
variable "enable_resource_name_dns_a_record_on_launch" {
  description = "Indicates whether to respond to DNS queries for instance hostnames with DNS A records."
  type        = bool
  default     = false
}

variable "environment" {
  description = "Name of environment"
  default     = "development"
}

# The service VPC will need to communicate to the management VPC
# To correctly create routes and peering links the module
# needs to know block of IP addresses of the management VPC
variable "management_cidr_block" {
  description = "Management VPC cidr block"
}

variable "restrict_all_traffic" {
  description = "Whether the default security group should deny all traffic"
  type        = bool
  default     = false
}

variable "service_name" {
  description = "Descriptive name of a service that will use this VPC"
}

variable "subnets" {
  description = "List of subnets in the VPC"
  type = list(object({
    cidr                    = string
    availability-zone       = string
    map_public_ip_on_launch = bool
    create_nat              = bool
    forward_to              = string
    tags                    = optional(map(string), {})
  }))
  default = []
}

variable "enable_vpc_flow_logs" {
  description = "Whether to enable VPC Flow Logs. Default, false."
  default     = false
}

variable "vpc_cidr_block" {
  description = "Block of IP addresses used for this VPC"
}

variable "tags" {
  description = "Tags to apply to each resource"
  default     = {}
}
