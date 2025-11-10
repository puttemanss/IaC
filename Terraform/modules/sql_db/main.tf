resource "azurerm_mssql_server" "sqlserver" {
  name                = var.server_name
  location            = var.location
  resource_group_name = var.resource_group_name
  version             = var.server_version

  azuread_administrator {
    login_username              = var.login_username
    object_id                   = var.object_id
    tenant_id                   = var.tenant_id
    azuread_authentication_only = true
  }

  public_network_access_enabled = !var.include_networking

  dynamic "identity" {
    for_each = length(var.user_assigned_identity_ids) > 0 ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = var.user_assigned_identity_ids
    }
  }

  tags = var.tags
}

resource "azurerm_mssql_database" "sqldb" {
  name         = var.database_name
  server_id    = azurerm_mssql_server.sqlserver.id
  license_type = var.database_license_type
  sku_name     = var.database_sku_name
  max_size_gb  = var.database_max_size_gb
  tags         = var.tags
}

module "pep_sqlserver" {
  count = var.include_networking ? 1 : 0

  source                = "../private_endpoint"
  name                  = "pep-sqlserver-${var.environment}"
  location              = var.location
  resource_group_name   = var.networking_resource_group_name
  subnet_id             = var.data_platform_subnet_id
  private_ip_address    = var.pep_sqlserver_ip
  resource_id           = azurerm_mssql_server.sqlserver.id
  resource_name         = azurerm_mssql_server.sqlserver.name
  subresource_name      = "sqlServer"
  member_name           = "sqlServer"
  private_dns_zone_name = "privatelink.database.windows.net"
  virtual_network_id    = var.vnet_id
  tags                  = var.tags
}
