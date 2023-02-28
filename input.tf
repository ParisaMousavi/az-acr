variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sku" {
  type = string
}

variable "admin_enabled" {
  type    = bool
  default = false
}

variable "name" {
  type = string
}

variable "additional_tags" {
  default = {}
  type    = map(string)
}


variable "private_endpoint_config" {
  type = object({
    subnet_id           = optional(string, null)
    private_dns_zone_id = optional(string)
  })
}

variable "public_network_access_enabled" {
  type    = bool
  default = true
}

variable "network_rule_set" {
  type = object({
    default_action   = optional(string, "Allow")
    allow_ip_ranges  = list(string)
    allow_subnet_ids = list(string)
  })

}