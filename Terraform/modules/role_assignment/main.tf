locals {
  assignments = zipmap(
    range(length(var.role_definition_list)),
    var.role_definition_list
  )

  filtered_assignments = { for k, v in local.assignments : k => v if v.create }
}

module "rbac" {
  for_each             = local.filtered_assignments
  source               = "./rbac"
  principal_id         = each.value.principal_id
  role_definition_name = each.value.role_definition_name
  scope                = each.value.scope
}
