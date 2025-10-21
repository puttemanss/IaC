variable "resource_group_name" {
  description = "The resource group in which the SQL server & db will be created."
  type        = string
}

variable "location" {
  description = "The location where the SQL server will be created."
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

variable "server_name" {
  description = "The name for the SQL server."
  type        = string
}

variable "server_version" {
  description = "The version for the SQL server."
  type        = string
}

variable "login_username" {
  description = "The login username of the Azure AD Administrator for the SQL Server."
  type        = string
}

variable "tenant_id" {
  description = "The id of the Azure tenant where this solution will be deployed."
  type        = string
}

variable "object_id" {
  description = "The object id in EntraID of the administrator for the SQL Server."
  type        = string
}

variable "database_name" {
  description = "The name for the SQL database."
  type        = string
}

variable "database_license_type" {
  description = "The type of license for the SQL database."
  type        = string
}

variable "database_sku_name" {
  description = "The sku for the SQL database."
  type        = string
}

variable "database_max_size_gb" {
  description = "The max size in GB that the SQL database can grow to."
  type        = number
}

variable "networking_resource_group_name" {
  description = "The name of the Resource Group where the networking resources will be created."
  type        = string
}

variable "vnet_id" {
  type        = string
  description = "The id of the vnet."
}

variable "data_platform_subnet_id" {
  description = "The id of the data platform subnet, used to create the Private Endpoint."
  type        = string
}

variable "pep_sqlserver_ip" {
  description = "The ip address that will be given to the sqlserver private endpoint."
  type        = string
}

variable "include_networking" {
  description = "Whether or not to include networking resources."
  type        = bool
}
