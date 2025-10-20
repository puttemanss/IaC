variable "name" {
  description = "The name for the Key Vault."
  type        = string
}

variable "location" {
  description = "The location for the Key Vault."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group to create the Key Vault in."
  type        = string
}

variable "networking_resource_group_name" {
  description = "The name of the Resource Group where the networking resources will be created."
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

variable "tenant_id" {
  description = "The id of the tenant where the solution is deployed."
  type        = string
}

variable "vnet_id" {
  type        = string
  description = "The id of the Virtual Network."
}

variable "data_platform_subnet_id" {
  description = "The id of the data platform subnet, used to create the Private Endpoint."
  type        = string
}

variable "pep_vault_ip" {
  description = "The ip address that will be given to the vault private endpoint."
  type        = string
}

variable "include_networking" {
  description = "Whether or not to include networking resources."
  type        = bool
}
