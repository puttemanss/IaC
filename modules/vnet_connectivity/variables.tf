/*
Flags
*/
variable "include_vpn_connection" {
  description = "Whether or not to deploy a Virtual Network Gateway to access the solution."
  type        = bool
}

variable "include_vm_connection" {
  description = "Whether or not to deply a Virtual Machine to access the solution."
  type        = bool
}

/*
General variables
*/
variable "networking_resource_group_name" {
  type        = string
  description = "The name of the resource group for the networking components."
}

variable "location" {
  description = "The location where the resources will be deployed to."
  type        = string
}

variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The name of the environment."
  type        = string
}

variable "tags" {
  description = "The tags to give."
  type        = map(string)
}

/*
VPN connection variables
*/
variable "vpn_GatewaySubnet_cidr_block" {
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

variable "vpn_tenant_id" {
  description = "The id of the tenant where the solution is deployed."
  type        = string
}

variable "vpn_vnet_name" {
  description = "The name of the vnet."
  type        = string
}

/*
VM connection variables
*/
variable "vm_resource_group_name" {
  description = "The name of the resource group for the Virtual Machine."
  type        = string
}

variable "vm_admin_username" {
  description = "The username of the local administrator used for the Virtual Machine."
  type        = string
}

variable "vm_admin_password" {
  description = "The password of the local administrator used for the Virtual Machine."
  type        = string
}

variable "vm_size" {
  description = "The SKU of the Virtual Machine."
  type        = string
}

variable "vm_nic_subnet_id" {
  description = "The id of the subnet in which the Virtual Machine exists."
  type        = string
}

variable "vm_nic_ip_address" {
  description = "The ip address that will be assigned to the VMs NIC."
  type        = string
}

variable "vm_source_image_reference" {
  description = "The source image reference for the Windows VM's OS."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}
