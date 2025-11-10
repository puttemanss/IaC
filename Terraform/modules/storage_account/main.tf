resource "azurerm_storage_account" "storage_account" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  account_tier             = "Standard"
  account_replication_type = var.account_replication_type
  account_kind             = "StorageV2"
  access_tier              = "Hot"
  is_hns_enabled           = true

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

resource "azurerm_storage_container" "bronze" {
  name                  = "bronze"
  storage_account_id    = azurerm_storage_account.storage_account.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "silver" {
  name                  = "silver"
  storage_account_id    = azurerm_storage_account.storage_account.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "gold" {
  name                  = "gold"
  storage_account_id    = azurerm_storage_account.storage_account.id
  container_access_type = "private"
}

module "pep_dfs" {
  count = var.include_networking ? 1 : 0

  source                = "../private_endpoint"
  name                  = "pep-dls-dfs-${var.environment}"
  location              = var.location
  resource_group_name   = var.networking_resource_group_name
  subnet_id             = var.data_platform_subnet_id
  private_ip_address    = var.pep_dfs_ip
  resource_id           = azurerm_storage_account.storage_account.id
  resource_name         = azurerm_storage_account.storage_account.name
  subresource_name      = "dfs"
  member_name           = "dfs"
  private_dns_zone_name = "privatelink.dfs.core.windows.net"
  virtual_network_id    = var.vnet_id
  tags                  = var.tags
}

module "pep_blob" {
  count = var.include_networking ? 1 : 0

  source                = "../private_endpoint"
  name                  = "pep-dls-blob-${var.environment}"
  location              = var.location
  resource_group_name   = var.networking_resource_group_name
  subnet_id             = var.data_platform_subnet_id
  private_ip_address    = var.pep_blob_ip
  resource_id           = azurerm_storage_account.storage_account.id
  resource_name         = azurerm_storage_account.storage_account.name
  subresource_name      = "blob"
  member_name           = "blob"
  private_dns_zone_name = "privatelink.blob.core.windows.net"
  virtual_network_id    = var.vnet_id
  tags                  = var.tags
}
