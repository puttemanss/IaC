output "subnet_id" {
  description = "The id of the created subnet."
  value       = azurerm_subnet.subnet.id
}

output "subnet_name" {
  description = "The name of the created subnet."
  value       = azurerm_subnet.subnet.name
}
