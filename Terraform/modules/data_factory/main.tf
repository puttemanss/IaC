resource "azurerm_data_factory" "data_factory" {
  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  managed_virtual_network_enabled = var.include_networking
  public_network_enabled          = !var.include_networking

  identity {
    type         = "UserAssigned"
    identity_ids = var.user_assigned_identity_ids
  }

  tags = var.tags
}

module "pep_datafactory" {
  count = var.include_networking ? 1 : 0

  source                = "../private_endpoint"
  name                  = "pep-datafactory-${var.environment}"
  location              = var.location
  resource_group_name   = var.networking_resource_group_name
  subnet_id             = var.data_platform_subnet_id
  private_ip_address    = var.pep_datafactory_ip
  resource_id           = azurerm_data_factory.data_factory.id
  resource_name         = azurerm_data_factory.data_factory.name
  subresource_name      = "dataFactory"
  member_name           = "dataFactory"
  private_dns_zone_name = "privatelink.datafactory.azure.net"
  virtual_network_id    = var.vnet_id
  tags                  = var.tags
}

module "pep_portal" {
  count = var.include_networking ? 1 : 0

  source                = "../private_endpoint"
  name                  = "pep-datafactory-portal-${var.environment}"
  location              = var.location
  resource_group_name   = var.networking_resource_group_name
  subnet_id             = var.data_platform_subnet_id
  private_ip_address    = var.pep_portal_ip
  resource_id           = azurerm_data_factory.data_factory.id
  resource_name         = azurerm_data_factory.data_factory.name
  subresource_name      = "portal"
  member_name           = "portal"
  private_dns_zone_name = "privatelink.adf.azure.net"
  virtual_network_id    = var.vnet_id
  tags                  = var.tags
}

#################################################
################ LINKED SERVICES ################
#################################################
resource "azurerm_data_factory_linked_service_key_vault" "keyvault_linked_service" {
  name            = "KeyVault_Linked_Service_${var.environment}"
  data_factory_id = azurerm_data_factory.data_factory.id
  description     = "Managed by Terraform"
  key_vault_id    = var.key_vault_id
}

resource "azurerm_data_factory_linked_service_azure_databricks" "databricks_linked_service" {
  count = var.create_dbr_linked_service ? 1 : 0

  name                = "Databricks_Linked_Service_${var.environment}"
  data_factory_id     = azurerm_data_factory.data_factory.id
  description         = "Managed by Terraform"
  adb_domain          = "https://${var.databricks_workspace_url}"
  existing_cluster_id = var.cluster_id

  key_vault_password {
    linked_service_name = azurerm_data_factory_linked_service_key_vault.keyvault_linked_service.name
    secret_name         = "databricks-token"
  }
}
