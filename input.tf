variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sku" {
  type    = string
}

variable "admin_enabled" {
  type    = bool
  default = false
}

variable "name" {
  type = string
}

variable "additional_tags" {
  default     = {}
  type        = map(string)
}
