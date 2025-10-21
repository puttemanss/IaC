variable "location" {
  description = "The location for the Databricks workspace."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group where the Databricks workspace will be created."
  type        = string
}

variable "networking_resource_group_name" {
  description = "The name of the Resource Group where the networking resources will be created."
  type        = string
}

variable "company_abbreviation" {
  description = "The abbreviation of the company name. Will be used to name the different resources."
  type        = string
}

variable "project_name" {
  description = "The name of the project. Will be used to name the different resources."
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

variable "vnet_name" {
  description = "The name of the Virtual Network where the networking resources will be created in."
  type        = string
}

variable "vnet_id" {
  description = "The id of the Virtual Network."
  type        = string
}

variable "data_platform_subnet_id" {
  description = "The id of the data platform subnet, used to create the Private Endpoint."
  type        = string
}

variable "public_network_cidr_block" {
  description = "The CIDR block for the Databricks public subnet."
  type        = string
}

variable "private_network_cidr_block" {
  description = "The CIDR block for the Databricks private subnet."
  type        = string
}

variable "pep_ui_api_ip" {
  description = "The ip address that will be given to the ui api private endpoint."
  type        = string
}

variable "pep_browser_authentication_ips" {
  description = "The ip addresses that will be given to the browser authentication private endpoint."
  type        = list(string)
}

variable "include_networking" {
  description = "Whether or not to include networking resources."
  type        = bool
}

variable "dls_storage_account_name" {
  description = "Name of storage account for which a storage credential will be created. (Optional)"
  type        = string
  default     = ""
}
variable "uc_metastore_id" {
  description = "The ID of the Unity Catalog metastore. (Optional)"
  type        = string
  default     = ""
}
variable "add_storage_credential" {
  description = "Whether or not to create storage credential with external locations."
  type        = bool
}

variable "devops_agent_ip" {
  description = "The IP Address of the DevOps Agent."
  type        = string
}

variable "schema_names" {
  description = "A list of schema names to create in this environments Databricks catalog."
  type        = list(string)
  default     = ["bronze", "silver", "gold"]
}

variable "first_environment" {
  description = "Whether or not you are deploying the first environment."
  type        = bool
}

variable "create_cluster" {
  description = "Whether or not a cluster will be created."
  type        = bool
}
