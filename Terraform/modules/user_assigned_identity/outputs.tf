output "id" {
  description = "The id of the created User Assigned Identity."
  value       = azurerm_user_assigned_identity.user_assigned_identity.id
}

output "principal_id" {
  description = "The pricipal id of the created User Assigned Identity."
  value       = azurerm_user_assigned_identity.user_assigned_identity.principal_id
}

output "client_id" {
  description = "The client id of the created User Assigned Identity."
  value       = azurerm_user_assigned_identity.user_assigned_identity.client_id
}
