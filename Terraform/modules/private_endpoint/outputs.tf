output "private_dns_zone_name" {
  description = "The name of the private dns zone created."
  value       = azurerm_private_dns_zone.private_dns_zone.name
}
