variable "name" {
  description = "The name for the Resource Group."
  type        = string
}

variable "location" {
  description = "The location for the Resource Group."
  type        = string
}

variable "tags" {
  description = "The tags to give."
  type        = map(string)
}
