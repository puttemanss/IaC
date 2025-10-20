variable "name" {
  description = "The name for the Function App."
  type        = string
}

variable "location" {
  description = "The location where the Function App will be created."
  type        = string
}

variable "resource_group_name" {
  description = "The resource group in which the Function will be created."
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

variable "storage_account_name" {
  description = "The name of the Storage Account that will be created for the Function."
  type        = string
}

variable "user_assigned_identity_ids" {
  description = "The ids of the User Assigned Identities that will be given to the Function."
  type        = list(string)
}

# ASP / Consumption
variable "kind" {
  description = "The kind of the Function App."
  type        = string
}

variable "sku_name" {
  description = "The SKU name for the Function App's Service Plan."
  type        = string
}

variable "runtime" {
  description = "The runtime that the Function should use."

  type = object({
    language = string
    version  = string
  })
}

variable "include_networking" {
  description = "Whether or not to include networking resources."
  type        = bool
}

variable "networking_resource_group_name" {
  description = "The name of the Resource Group where the networking resources will be created."
  type        = string
}

variable "data_platform_subnet_id" {
  description = "The id of the data platform subnet, used to create the Private Endpoint."
  type        = string
}

variable "vnet_id" {
  type        = string
  description = "The id of the vnet."
}

variable "pep_sites_ip" {
  description = "The ip address that will be given to the sites private endpoint."
  type        = string
}

variable "data_platform_subnet_cidr_block" {
  description = "The CIDR block of the data platform subnet, used for allowing access to the function site."
  type        = string
}

variable "azure_function_subnet_cidr_block" {
  description = "The CIDR block to be given to the azure-function subnet."
  type        = string
}

variable "vnet_name" {
  description = "The name of the vnet."
  type        = string
}

variable "data_platform_nsg_name" {
  description = "The name of the data-platform network security group, used to add a rule that the integration subnet can access the data-platform subnet."
  type        = string
}
