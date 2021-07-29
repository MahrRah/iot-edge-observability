variable "resource_prefix" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vm_user_name" {
  type = string
}

variable "vm_sku" {
  type    = string
  default = "Standard_DS1_v2"
}

variable "edge_vm_name" {
  type = string
}

variable "device_connection_string" {
  type = string
}