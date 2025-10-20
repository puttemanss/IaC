variable "name" {
  description = "The name for the User Assigned Identity."
  type        = string
}
variable "location" {
  description = "The location for the User Assigned Identity."
  type        = string
}
variable "resource_group_name" {
  description = "The name of the Resource Group to create the User Assigned Identity in."
  type        = string
}

variable "tags" {
  description = "The tags to give."
  type        = map(string)
}
