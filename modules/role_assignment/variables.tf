variable "role_definition_list" {
  description = "A list of role definitions to be applied."
  type = list(object({
    create               = bool
    principal_id         = string
    role_definition_name = string
    scope                = string
  }))
}
