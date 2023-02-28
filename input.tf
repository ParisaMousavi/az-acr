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


variable "network_config" {
  type = object({
    virtual_network_id = string
    subnet_id          = string
  })
}

variable "public_network_access_enabled" {
  type = bool
  default = true
}

variable "network_rule_set" {
  type= object({
    allow_ip_ranges = list(string)
    allow_subnet_ids = list(string)
  }) 
}