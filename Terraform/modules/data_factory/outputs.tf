output "id" {
  description = "The id of the created Data Factory."
  value       = azurerm_data_factory.data_factory.id
}

output "principal_id" {
  description = "The principal id of the created Data Factory."
  value = azurerm_data_factory.data_factory.identity[0].principal_id
}
