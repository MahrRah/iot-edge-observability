variable "resource_group_location" {
  type    = string
  default = "West Europe"
}

# User of the IoT Edge VM
variable "edge_vm_user_name" {
  type    = string
  default = "" # The default value is empty, but in the usages of this variable it will be overridden by a generated value if left empty.
}


variable "edge_vm_sku" {
  type    = string
  default = "Standard_DS1_v2" # "Standard_NC4as_T4_v3"  The default is for GPU enabled VMs

}

variable "log_analytics_retention_period" {
  type        = number
  description = "number of days to retain logs in azure log analytics"
  default     = 30
}
