variable "enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC. Defaults true."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC. Defaults true."
  type        = bool
  default     = true
}
variable "enable_resource_name_dns_a_record_on_launch" {
  description = "Indicates whether to respond to DNS queries for instance hostnames with DNS A records."
  type        = bool
  default     = false
}

variable "environment" {
  description = "Name of environment"
  type        = string
}

# The service VPC will need to communicate to the management VPC
# To correctly create routes and peering links the module
# needs to know block of IP addresses of the management VPC
variable "management_cidr_block" {
  description = "Management VPC cidr block"
  type        = string

  validation {
    condition     = can(cidrhost(var.management_cidr_block, 0))
    error_message = "management_cidr_block must be a valid IPv4 CIDR block (e.g., 10.0.0.0/16)"
  }
}

variable "restrict_all_traffic" {
  description = "Whether the default security group should deny all traffic"
  type        = bool
  default     = true
}

variable "default_security_group_cidr" {
  description = <<-EOT
    CIDR block for the default security group rules when restrict_all_traffic is false.
    If null, defaults to the VPC CIDR block.
  EOT
  type        = string
  default     = null
}

variable "service_name" {
  description = "Descriptive name of a service that will use this VPC"
  type        = string
}

variable "subnets" {
  description = "List of subnets in the VPC"
  type = list(
    object(
      {
        cidr                    = string
        availability_zone       = optional(string, null)
        availability-zone       = optional(string, null) # Deprecated, use availability_zone
        map_public_ip_on_launch = optional(bool, false)
        create_nat              = optional(bool, false)
        forward_to              = optional(string, null)
        tags                    = optional(map(string), {})
      }
    )
  )
  default = []
}

variable "enable_vpc_flow_logs" {
  description = "Whether to enable VPC Flow Logs. Default, true."
  type        = bool
  default     = true
}

variable "flow_logs_force_destroy" {
  description = "Whether to force destroy the VPC flow logs S3 bucket and all its contents on deletion."
  type        = bool
  default     = false
}

variable "vpc_cidr_block" {
  description = "Block of IP addresses used for this VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr_block, 0))
    error_message = "vpc_cidr_block must be a valid IPv4 CIDR block (e.g., 10.0.0.0/16)"
  }
}

variable "tags" {
  description = "Tags to apply to each resource"
  type        = map(string)
  default     = {}
}

variable "vpc_flow_retention_days" {
  description = "Retention period for VPC flow logs in S3 bucket."
  type        = number
  default     = 365
}
