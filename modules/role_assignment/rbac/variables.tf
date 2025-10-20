variable "principal_id" {
  description = "The object ID of the user, group, or service principal"
  type        = string
}

variable "role_definition_name" {
  description = "The name of the role to assign (e.g., 'Contributor')"
  type        = string
}

variable "scope" {
  description = "The scope at which the role assignment applies (e.g., a resource group or subscription)"
  type        = string
}
