output "access_connector_principal_id" {
  description = "The id of the created Databricks Access Connector."
  value       = data.azurerm_databricks_access_connector.databricks_access_connector.identity[0].principal_id
}

output "access_connector_id" {
  description = "The id of the created Databricks Access Connector."
  value       = data.azurerm_databricks_access_connector.databricks_access_connector.id
}

output "host" {
  description = "The Databricks workspace URL"
  value       = azurerm_databricks_workspace.databricks_workspace.workspace_url
}

output "workspace_id" {
  description = "The id of the created Databricks Workspace."
  value       = azurerm_databricks_workspace.databricks_workspace.id
}

output "workspace_url" {
  description = "The url of the created Databricks Workspace."
  value       = azurerm_databricks_workspace.databricks_workspace.workspace_url
}

output "token" {
  description = "Databricks token which will be used for ADF connection."
  value       = databricks_token.token.token_value
  sensitive   = true
}

output "adf_cluster_id" {
  description = "The id of the cluster for adf's linked service."
  value       = databricks_cluster.adf_cluster[0].id
}
