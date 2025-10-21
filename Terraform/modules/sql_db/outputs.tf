output "sql_server_id" {
  description = "The id of the created SQL server."
  value       = azurerm_mssql_server.sqlserver.id
}
