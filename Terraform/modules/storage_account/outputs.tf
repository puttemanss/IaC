output "id" {
  description = "The id of the created Storage Account."
  value       = azurerm_storage_account.storage_account.id
}

output "name" {
  description = "The name of the created Storage Account."
  value       = azurerm_storage_account.storage_account.name
}
