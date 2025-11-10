variable "name" {
  description = "The name for the Storage Account."
  type        = string
}
variable "location" {
  description = "The location for the Storage Account."
  type        = string
}
variable "resource_group_name" {
  description = "The name of the Resource Group to create the Storage Account in."
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

variable "vnet_id" {
  type        = string
  description = "The id of the vnet."
}

variable "data_platform_subnet_id" {
  description = "The id of the data platform subnet, used to create the Private Endpoint."
  type        = string
}

variable "pep_dfs_ip" {
  description = "The ip address that will be given to the dfs private endpoint."
  type        = string
}

variable "pep_blob_ip" {
  description = "The ip address that will be given to the blob private endpoint."
  type        = string
}

variable "include_networking" {
  description = "Whether or not to include networking resources."
  type        = bool
}

variable "account_replication_type" {
  description = "The type of replication to use for the storage account."
  type        = string
}

variable "user_assigned_identity_ids" {
  description = "List of User Assigned Identity IDs to assign to the Storage Account."
  type        = list(string)
  default     = []
}
