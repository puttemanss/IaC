variable "name" {
  description = "The name for the subnet that will be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy the subnet to."
  type        = string
}

variable "vnet_name" {
  description = "The name of the virtual network where the subnet will be created in."
  type        = string
}

variable "cidr_block" {
  description = "The CIDR block associated with the subnet that will be created."
  type        = string
}
