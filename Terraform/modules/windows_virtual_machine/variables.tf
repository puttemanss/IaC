variable "admin_username" {
  description = "The username of the local administrator used for the Virtual Machine."
  type        = string
}

variable "admin_password" {
  description = "The password of the local administrator used for the Virtual Machine."
  type        = string
}

variable "location" {
  description = "The location where the resources will be deployed to."
  type        = string
}

variable "name" {
  description = "The name for the Virtual Machine."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy the VM in."
  type        = string
}

variable "size" {
  description = "The SKU of the Virtual Machine."
  type        = string
}

variable "subnet_id" {
  description = "The id of the subnet in which the Virtual Machine exists."
  type        = string
}

variable "ip_address" {
  description = "The ip address that will be assigned to the VMs NIC."
  type        = string
}

variable "networking_resource_group_name" {
  type        = string
  description = "The name of the resource group for the networking components."
}

variable "source_image_reference" {
  description = "The source image reference for the Windows VM's OS."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

variable "tags" {
  description = "The tags to give."
  type        = map(string)
}
