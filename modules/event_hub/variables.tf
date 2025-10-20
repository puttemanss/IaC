variable "namespace_name" {
  description = "The name for the Event Hub namespace."
  type        = string
}

variable "location" {
  description = "The location where the Event Hub will be created."
  type        = string
}

variable "resource_group_name" {
  description = "The resource group in which the Event Hub will be created."
  type        = string
}

variable "user_assigned_identity_ids" {
  description = "The ids of the User Assigned Identities that will be given to the Data Factory."
  type        = list(string)
}

variable "sku" {
  description = "The tier of the Event Hub namespace."
  type        = string
}

variable "capacity" {
  description = "The capacity / throughput units."
  type        = number
}

variable "auto_inflate_enabled" {
  description = "Whether or not to enable auto inflate for the Event Hub namespace."
  type        = bool
}

variable "maximum_throughput_units" {
  description = "The maximum capacity / throughput units that the Event Hub can scale to."
  type        = number
}

variable "event_hub_name" {
  description = "The name for the Event Hub."
  type        = string
}

variable "partition_count" {
  description = "The partition count for the Event Hub."
  type        = number
}

variable "message_retention" {
  description = "Number of days to retain the events."
  type        = number
}

variable "enable_data_capture" {
  description = "Whether or not to enable data_capture."
  type        = bool
}

variable "capture_interval" {
  description = "The interval in seconds to capture data."
  type        = number
}

variable "capture_storage_account_id" {
  description = "The id of the storage account to store the data captures in."
  type        = string
}

variable "capture_blob_container_name" {
  description = "The name of the blob container to store the data captures in."
  type        = string
}

variable "include_networking" {
  description = "Whether or not to include networking resources."
  type        = bool
}

variable "environment" {
  description = "The name of the environment."
  type        = string
}

variable "tags" {
  description = "The tags to give."
  type        = map(string)
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

variable "pep_namespace_ip" {
  description = "The ip address that will be given to the namespace private endpoint."
  type        = string
}
