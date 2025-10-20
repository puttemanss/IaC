variable "name" {
  description = "The name for the Data Factory."
  type        = string
}

variable "location" {
  description = "The location for the Data Factory."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group where the Data Factory will be created."
  type        = string
}

variable "networking_resource_group_name" {
  description = "The name of the Resource Group where the networking resources will be created."
  type        = string
}

variable "user_assigned_identity_ids" {
  description = "The ids of the User Assigned Identities that will be given to the Data Factory."
  type        = list(string)
}

variable "environment" {
  description = "The name of the environment."
  type        = string
}

variable "tags" {
  description = "The tags to give."
  type        = map(string)
}

variable "vnet_id" {
  type        = string
  description = "The id of the vnet."
}

variable "data_platform_subnet_id" {
  description = "The id of the data platform subnet, used to create the Private Endpoint."
  type        = string
}

variable "pep_datafactory_ip" {
  description = "The ip address that will be given to the datafactory private endpoint."
  type        = string
}

variable "pep_portal_ip" {
  description = "The ip address that will be given to the datafactory portal private endpoint."
  type        = string
}

variable "include_networking" {
  description = "Whether or not to include networking resources."
  type        = bool
}

variable "key_vault_id" {
  description = "The id of the Key Vault for which a linked service will be created."
  type        = string
}

variable "uai_key_vault_secrets_officer_uai_id" {
  description = "The id of the Key Vault Secrets Officer User Assigned Identity for which to create a secret."
  type = string
}

variable "create_dbr_linked_service" {
  description = "Whether or not to create the Databricks linked service."
  type        = bool
}

variable "databricks_workspace_url" {
  description = "The workspace url of the databricks workspace. Used for the linked service."
  type        = string
}

variable "cluster_id" {
  description = "The id of the existing databricks cluster. Used for the linked service."
  type        = string
}
