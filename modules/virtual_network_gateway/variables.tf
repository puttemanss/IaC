variable "resource_group_name" {
  type        = string
  description = "The name of the resource group for the networking components."
}

variable "location" {
  description = "The location where the resources will be deployed to."
  type        = string
}

variable "tenant_id" {
  description = "The id of the tenant where the solution is deployed."
  type        = string
}

variable "name" {
  description = "The name to give the Virtual Network Gateway."
  type        = string
}

variable "vnet_name" {
  type        = string
  description = "The name of the vnet."
}

variable "GatewaySubnet_cidr_block" {
  description = "The CIDR block for the GatewaySubnet."
  type        = string
}

variable "vpn_configuration_address_space_cidr_block" {
  description = "Address space for VPN clients."
  type        = string
}

variable "vpn_application_id" {
  description = "The application id of the Azure VPN in Entra ID."
  type        = string
}

variable "tags" {
  description = "The tags to give."
  type        = map(string)
}
