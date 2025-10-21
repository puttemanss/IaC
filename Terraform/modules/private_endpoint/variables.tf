variable "name" {
  description = "The name to be given to the private endpoint."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which the private endpoint should be created."
  type        = string
}

variable "location" {
  description = "The location where the private endpoint will be deployed to."
  type        = string
}

variable "tags" {
  description = "The tags to give."
  type        = map(string)
}

variable "subnet_id" {
  description = "The ID of the subnet where the private endpoint must be deployed in."
  type        = string
}

variable "private_ip_address" {
  description = "The private ip address that the endpoint should have."
  type        = string
}

variable "resource_id" {
  description = "The ID of the resource for which the private endpoint will be created."
  type        = string
}

variable "resource_name" {
  description = "The name of the resource for which the private endpoint will be created."
  type        = string
}

variable "subresource_name" {
  description = "The name of the subresource for which the private endpoint will be created."
  type        = string
}

variable "member_name" {
  description = "Specifies the member name this IP address applies to."
  type        = string
}

variable "private_dns_zone_name" {
  description = "The name for the private dns zone linked to the private endpoint."
  type        = string
}

variable "virtual_network_id" {
  description = "The ID of the virtual network."
  type        = string
}
